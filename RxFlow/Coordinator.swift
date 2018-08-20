//
//  Coordinator.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-25.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxSwift

/// Delegate used to communicate from a FlowCoordinator
protocol FlowCoordinatorDelegate: class {

    /// Used to tell the delegate that a new child Flow is to be coordinated
    ///
    /// - Parameters:
    ///   - parentFlowCoordinator: the FlowCoordinator that triggers the new Flow
    ///   - nextFlowItem: the NextFlowItem that has triggered the navigation to a new child Flow
    func navigateToAnotherFlow (withParentFlowCoordinator parentFlowCoordinator: FlowCoordinator, withNextFlowItem nextFlowItem: NextFlowItem)

    /// Used to tell the delegate the Flow has ended and it must free the FlowCoordinator
    ///
    /// - Parameter identifier: the FlowCoordinator identifier (used to reference the FlowCoordinator in the Coordinator)
    func endFlowCoordinator (withIdentifier identifier: String)

    /// Used to trigger the delegate before the Flow/Step is handled
    ///
    /// - Parameters:
    ///   - stepContext: the StepContext that is being navigated to
    func willNavigate (to stepContext: StepContext)

    /// Used to trigger the delegate after the Flow/Step is handled
    ///
    /// - Parameters:
    ///   - stepContext: the StepContext that is being navigated to
    func didNavigate (to stepContext: StepContext)
}

/// A FlowCoordinator handles the navigation inside a dedicated Flow
/// It will listen for Steps emitted be the Flow's Stepper companion or
/// the Steppers produced by the Flow.navigate(to:) function along the way
class FlowCoordinator: HasDisposeBag {

    /// The FlowCoordinator that has triggered this Flow
    fileprivate var parentFlowCoordinator: FlowCoordinator?

    /// The Flow to be coordinated
    private let flow: Flow

    /// The Stepper that drives the Flow
    /// It will trigger some Steps at the Flow level
    private let stepper: Stepper

    /// The Rx subject that holds all the Steps trigerred either by the Flow's Stepper
    /// or by the Steppers produced by the Flow.navigate(to:) function
    /// To be more precise, it is a Stream of StepContexts.
    /// Such a context holds some extra info about the step (for instance, a Bool associated with
    /// the Step indicating whether the Step comes from the Flow itself or a child Flow)
    private let steps = PublishSubject<StepContext>()

    /// The delegate allows the FlowCoordinator to communicate with the Coordinator
    /// in the case of a new Flow to coordinate or before and after a navigation action
    private weak var delegate: FlowCoordinatorDelegate!

    /// the unique identifier of the FlowCoordinator, used to remove if from the FlowCoordinators array in the main Coordinator
    let identifier: String

    /// Initialize a FlowCoordinator
    ///
    /// - Parameter flow: The Flow to coordinate
    /// - Parameter stepper: The Stepper associated to the Flow. For instance it will trigger the first Step
    /// - Parameter delegate: The Flow delegate that will we triggered when a navigation action happens
    /// - Parameter parentFlowCoordinator: The parent FlowCoordinator
    init(for flow: Flow,
         withStepper stepper: Stepper,
         withDelegate delegate: FlowCoordinatorDelegate,
         withParentFlowCoordinator parentFlowCoordinator: FlowCoordinator? = nil) {
        self.flow = flow
        self.stepper = stepper
        self.delegate = delegate
        self.parentFlowCoordinator = parentFlowCoordinator
        self.identifier = "\(type(of: flow))-\(UUID().uuidString)"
    }

    /// Launch the coordination process
    ///
    /// - Parameter stepper: The Stepper that goes with the Flow. It will trigger some Steps at the Flow level
    func coordinate () {

        self.steps
            .do(onNext: { [unowned self] (stepContext) in
                // trigger the delegate before the navigation is done
                self.delegate.willNavigate(to: stepContext)
            })
            .map { [unowned self] (stepContext) -> (StepContext, NextFlowItems) in
                // do the navigation according to the Flow and the Step
                // Retrieve the NextFlowItems
                return (stepContext, self.flow.navigate(to: stepContext.step))
            }.do(onNext: { [unowned self] (stepContext, _) in
                // when first presentable is discovered we can assume the Flow is ready to be used (its root can be used in other Flows)
                self.flow.flowReadySubject.onNext(true)

                // trigger the delegate after the navigation is done
                // the step will be handle whithin the Flow that is concerned by this very FlowCoordinator
                stepContext.withinFlow = self.flow
                self.delegate.didNavigate(to: stepContext)
            }).map { [unowned self] (stepContext, nextFlowItems) -> (StepContext, [NextFlowItem]) in
                switch nextFlowItems {
                case .multiple(let flowItems):
                    return (stepContext, flowItems)
                case .one(let flowItem):
                    return (stepContext, [flowItem])
                case .end(let stepToSendToParentFlow):
                    // if the navigation gives a "end" NextFlowItems, the FlowCoordinator
                    // triggers its parent FlowCoordinator with the specified step. It will allow the parent
                    // to dismiss the child Flow Root for instance (because this is the parent who had the responsability
                    // to present the child Flow Root as well)
                    if  let parentFlowCoordinator = self.parentFlowCoordinator {
                        let stepContextForParentFlow = StepContext(with: stepToSendToParentFlow)
                        stepContextForParentFlow.fromChildFlow = self.flow
                        parentFlowCoordinator.steps.onNext(stepContextForParentFlow)
                    }

                    // we tell the delegate that the FlowCoordinator is ended. This will
                    // unretain the FlowCoordinator reference from the main Coordinator
                    self.delegate.endFlowCoordinator(withIdentifier: self.identifier)

                    return (stepContext, [NextFlowItem]())
                case .triggerParentFlow(let stepToSendToParentFlow):
                    // if the navigation gives a "triggerParentFlow" NextFlowItems, the FlowCoordinator
                    // triggers its parent FlowCoordinator with the specified step. It will allow the parent
                    // to perform specific actions but without stopping listening for steppers in the current FlowCoordinator
                    // It can be useful in case of a tabbar navigation to allow a Flow that represents a tab to communicate
                    // with the parent Flow that handles the whole tabbar
                    if  let parentFlowCoordinator = self.parentFlowCoordinator {
                        let stepContextForParentFlow = StepContext(with: stepToSendToParentFlow)
                        stepContextForParentFlow.fromChildFlow = self.flow
                        parentFlowCoordinator.steps.onNext(stepContextForParentFlow)
                    }

                    return (stepContext, [NextFlowItem]())
                case .none:
                    return (stepContext, [NextFlowItem]())
                }
            }
            .flatMap { (arg) -> Observable<NextFlowItem> in
                // flatten the Observable<[NextFlowItem]> into Observable<NextFlowItem>
                // we know which NextFlowItem have been produced by this navigation action
                // each one of these NextFlowItems will lead to other navigation actions (for example, new Flows to handle and new Steppers to listen)
                let (_, nextFlowItems) = arg
                return Observable.from(nextFlowItems)
            }
            .do(onNext: { [unowned self] (nextFlowItem) in
                // if the NextFlowItem's next presentable represents a Flow, it has to be processed at a higher level because
                // the FlowCoordinator only knowns about the Flow it's in charge of.
                // The FlowCoordinator will expose the new Flow through its delegate
                if nextFlowItem.nextPresentable is Flow {
                    self.delegate.navigateToAnotherFlow(withParentFlowCoordinator: self, withNextFlowItem: nextFlowItem)
                }
            })
            .filter { (nextFlowItem) -> Bool in
                // at that point, only the NextFlowItems that handle a non Flow nextPresentable
                // should be processed
                return !(nextFlowItem.nextPresentable is Flow)
            }
            .flatMap { (nextFlowItem) -> Observable<Step> in
                // Steps are ok to be listened to. The steps can only be triggerd
                // when the presentable is displayed
                let presentable = nextFlowItem.nextPresentable
                let stepper = nextFlowItem.nextStepper
                return stepper
                    .steps
                    .pausable(withPauser: presentable.rxVisible)
            }
            .takeUntil(self.flow.rxDismissed.asObservable())
            .asDriver(onErrorJustReturn: NoneStep()).drive(onNext: { [weak self] (step) in
                // the nextPresentable's Stepper fires a new Step
                let newStepContext = StepContext(with: step)
                self?.steps.onNext(newStepContext)
            }).disposed(by: flow.disposeBag)

        // we listen for the Flow dedicated Stepper to drive the internal "steps" PublishSubject<StepContext>
        self.stepper
            .steps
            .pausable(afterCount: 1, withPauser: self.flow.rxVisible)
            .asDriver(onErrorJustReturn: NoneStep())
            .drive(onNext: { [weak self] (step) in
                // the Flow's Stepper fires a new Step (the initial Step for exemple)
                let newStepContext = StepContext(with: step)
                newStepContext.withinFlow = self?.flow
                self?.steps.onNext(newStepContext)
            }).disposed(by: flow.disposeBag)

        // we listen for the Flow root dismissal state. In case of a dismiss
        // the FlowCoordinate should be ended (its reference has to be unretain from the main Coordinator)
        self.flow.rxDismissed.subscribe(onSuccess: { [weak self] in
            // there is a risk that "self" is already deallocated as it could have
            // been unretained by the main Coordinator (after the self.delegate.endFlowCoordinator(withIdentifier: self.identifier)
            // statement in the subscription chain
            guard let strongSelf = self else { return }
            strongSelf.delegate.endFlowCoordinator(withIdentifier: strongSelf.identifier)
        }).disposed(by: flow.disposeBag)

    }
}

/// The only purpose of a Coordinator is to handle the navigation that is
/// declared in the Flows of the application.
final public class Coordinator: HasDisposeBag, Synchronizable {

    private var flowCoordinators = [String: FlowCoordinator]()
    fileprivate let willNavigateSubject = PublishSubject<(Flow, Step)>()
    fileprivate let didNavigateSubject = PublishSubject<(Flow, Step)>()

    /// Initialize the Coordinator
    public init() {
    }

    /// Launch the coordination process
    ///
    /// - Parameters:
    ///   - flow: The Flow to coordinate
    ///   - stepper: The Flow's Stepper companion that will determine the first navigation Steps for instance
    public func coordinate (flow: Flow, withStepper stepper: Stepper) {
        self.coordinate(flow: flow, withStepper: stepper, withParentFlowCoordinator: nil)
    }

    /// Launch the coordination process
    ///
    /// - Parameters:
    ///   - flow: The Flow to coordinate
    ///   - stepper: The Flow's Stepper companion that will determine the first navigation Steps for instance
    ///   - parentFlowCoordinator: The parent FlowCoordinator. The parent is warned in case of a noNavigation NextFlowItem in its children
    internal func coordinate (flow: Flow, withStepper stepper: Stepper, withParentFlowCoordinator parentFlowCoordinator: FlowCoordinator? = nil) {

        // a new FlowCoordinator will handle this Flow navigation
        let flowCoordinator = FlowCoordinator(for: flow,
                                              withStepper: stepper,
                                              withDelegate: self,
                                              withParentFlowCoordinator: parentFlowCoordinator)

        if let parentFlowCoordinator = parentFlowCoordinator {
            flowCoordinator.parentFlowCoordinator = parentFlowCoordinator
        }

        // we stack the FlowCoordinators so that we do not lose there reference (whereas it could be a leak)
        self.synchronized { [unowned self] in
            self.flowCoordinators[flowCoordinator.identifier] = flowCoordinator
        }

        // let's coordinate the Flow
        flowCoordinator.coordinate()
    }
}

extension Coordinator: FlowCoordinatorDelegate {

    func navigateToAnotherFlow (withParentFlowCoordinator parentFlowCoordinator: FlowCoordinator, withNextFlowItem nextFlowItem: NextFlowItem) {

        if let nextFlow = nextFlowItem.nextPresentable as? Flow {
            self.coordinate(flow: nextFlow, withStepper: nextFlowItem.nextStepper, withParentFlowCoordinator: parentFlowCoordinator)
        }
    }

    func endFlowCoordinator(withIdentifier identifier: String) {
        _ = self.synchronized { [unowned self] in
            self.flowCoordinators.removeValue(forKey: identifier)
        }
    }

    func willNavigate(to stepContext: StepContext) {
        if let withinFlow = stepContext.withinFlow,
            !(stepContext.step is NoneStep) {
            self.willNavigateSubject.onNext((withinFlow, stepContext.step))
        }
    }

    func didNavigate(to stepContext: StepContext) {
        if let withinFlow = stepContext.withinFlow,
            !(stepContext.step is NoneStep) {
            self.didNavigateSubject.onNext((withinFlow, stepContext.step))
        }
    }
}

// swiftlint:disable identifier_name
extension Coordinator {

    /// Reactive extension to a Loom
    public var rx: Reactive<Coordinator> {
        return Reactive(self)
    }
}
// swiftlint:enable identifier_name

extension Reactive where Base: Coordinator {

    /// Rx Observable triggered before the Coordinator navigates a Flow/Step
    public var willNavigate: Observable<(Flow, Step)> {
        return self.base.willNavigateSubject.asObservable()
    }

    /// Rx Observable triggered after the Coordinator navigates a Flow/Step
    public var didNavigate: Observable<(Flow, Step)> {
        return self.base.didNavigateSubject.asObservable()
    }
}
