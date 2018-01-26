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

    /// Used to triggered the delegate before the Flow/Step is handled
    ///
    /// - Parameters:
    ///   - flow: the Flow that is being navigated
    ///   - step: the Step that is being navigated
    func willNavigate (to flow: Flow, with step: Step)

    /// Used to triggered the delegate after the Flow/Step is handled
    ///
    /// - Parameters:
    ///   - flow: the Flow that is being navigated
    ///   - step: the Step that is being navigated
    func didNavigate (to flow: Flow, with step: Step)
}

/// A FlowCoordinator handles the navigation inside a dedicated Flow
/// It will listen for Steps emitted be the Flow's Stepper companion or
/// the Steppers produced by the Flow.navigate(to:) function along the way
class FlowCoordinator: HasDisposeBag {

    /// The FlowCoordinator that has triggered this Flow
    internal var parentFlowCoordinator: FlowCoordinator?

    /// The Flow to be coordinated
    private let flow: Flow

    /// The Stepper that drives the Flow
    /// It will trigger some Steps at the Flow level
    private let stepper: Stepper

    /// The Rx subject that holds all the Steps trigerred either by the Flow's Stepper
    /// or by the Steppers produced by the Flow.navigate(to:) function
    /// There is also a Bool associted with the Step indicating wheter the Step
    /// comes from the Flow itself or a child Flow
    private let steps = PublishSubject<(Step, Bool)>()

    /// The delegate allows the FlowCoordinator to communicate with the Coordinator
    /// in the case of a new Flow to coordinate or before and after a navigation action
    private weak var delegate: FlowCoordinatorDelegate!

    /// Initialize a FlowCoordinator
    ///
    /// - Parameter flow: The Flow to coordinate
    /// - Parameter stepper: The Stepper associated to the Flow. For instance it will trigger the first Step
    /// - Parameter delegate: The Flow delegate that will we triggered when a navigation action happens
    /// - Parameter parentFlowCoordinator: The parent FlowCoordinator
    init(for flow: Flow,
         andStepper stepper: Stepper,
         withDelegate delegate: FlowCoordinatorDelegate,
         withParrentFlowCoordinator parentFlowCoordinator: FlowCoordinator? = nil) {
        self.flow = flow
        self.stepper = stepper
        self.delegate = delegate
        self.parentFlowCoordinator = parentFlowCoordinator
    }

    /// Launch the coordination process
    ///
    /// - Parameter stepper: The Stepper that goes with the Flow. It will trigger some Steps at the Flow level
    func coordinate () {

        _ = self.steps
            .do(onNext: { [unowned self] (step) in
                // trigger the delegate before the navigation is done
                let (step, _) = step
                self.delegate.willNavigate(to: self.flow, with: step)
            })
            .map { [unowned self] (step) -> (Step, [NextFlowItem]) in
                let (step, fromFlow) = step

                // do the navigation according to the Flow and the Step
                // Retrieve the NextFlowItems
                let nextFlowItems = self.flow.navigate(to: step)

                switch nextFlowItems {
                case .multiple(let flowItems):
                    return (step, flowItems)
                case .one(let flowItem):
                    return (step, [flowItem])
                case .none:
                    return (step, [NextFlowItem]())
                case .stepNotHandled:
                    // if the navigation gives a "stepNotHandled" NextFlowItems, the FlowCoordinator
                    // triggers its parent FlowCoordinator with the same step. It will allow the parent
                    // to dismiss the child Flow  for instance(because this is tha parent who had the responsability
                    // to present the child Flow as well)
                    if  let parentFlowCoordinator = self.parentFlowCoordinator,
                        fromFlow {
                        parentFlowCoordinator.steps.onNext((step, false))
                    }
                    return (step, [NextFlowItem]())
                }
            }
            .do(onNext: { [unowned self] (step, _) in
                // when first presentable is discovered we can assume the Flow is ready to be used (its root can be used in other Flows)
                self.flow.flowReadySubject.onNext(true)

                // trigger the delegate after the navigation is done
                self.delegate.didNavigate(to: self.flow, with: step)
            })
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
            .asDriver(onErrorJustReturn: NoStep()).drive(onNext: { [weak self] (step) in
                // the nextPresentable's Stepper fires a new Step
                self?.steps.onNext((step, true))
            })

        // we listen for the Warp dedicated Weftable
        self.stepper
            .steps
            .pausable(afterCount: 1, withPauser: self.flow.rxVisible)
            .asDriver(onErrorJustReturn: NoStep())
            .drive(onNext: { [weak self] (step) in
                // the Flow's Stepper fires a new Step (the initial Step for exemple)
                self?.steps.onNext((step, true))
            }).disposed(by: flow.disposeBag)

    }
}

/// The only purpose of a Coordinator is to handle the navigation that is
/// declared in the Flows of the application.
final public class Coordinator: HasDisposeBag {

    private var flowCoordinators = [FlowCoordinator]()
    internal let willNavigateSubject = PublishSubject<(String, String)>()
    internal let didNavigateSubject = PublishSubject<(String, String)>()

    /// Initialize the Coordinator
    public init() {
    }

    /// Launch the coordination process
    ///
    /// - Parameters:
    ///   - flow: The Flow to coordinate
    ///   - stepper: The Flow's Stepper companion that will determine the first navigation Steps for instance
    public func coordinate (flow: Flow, withStepper stepper: Stepper) {
        self.coordinate(flow: flow, withStepper: stepper, withParrentFlowCoordinator: nil)
    }

    /// Launch the coordination process
    ///
    /// - Parameters:
    ///   - flow: The Flow to coordinate
    ///   - stepper: The Flow's Stepper companion that will determine the first navigation Steps for instance
    ///   - parentFlowCoordinator: The parent FlowCoordinator. The parent is warned in case of a noNavigation NextFlowItem in its children
    internal func coordinate (flow: Flow, withStepper stepper: Stepper, withParrentFlowCoordinator parentFlowCoordinator: FlowCoordinator? = nil) {

        // a new FlowCoordinator will handle this Flow navigation
        let flowCoordinator = FlowCoordinator(for: flow, andStepper: stepper, withDelegate: self, withParrentFlowCoordinator: parentFlowCoordinator)

        if let parentFlowCoordinator = parentFlowCoordinator {
            flowCoordinator.parentFlowCoordinator = parentFlowCoordinator
        }

        // we stack the FlowCoordinators so that we do not lose there reference (whereas it could be a leak)
        self.flowCoordinators.append(flowCoordinator)

        // let's coordinate the Flow
        flowCoordinator.coordinate()

        // clear the fFowCoordinators stack when the Flow has been dismissed (its root has been dismissed)
        let flowIndex = self.flowCoordinators.count-1
        flow.rxDismissed.subscribe(onSuccess: { [unowned self] (_) in
            self.flowCoordinators.remove(at: flowIndex)
        }).disposed(by: self.disposeBag)
    }
}

extension Coordinator: FlowCoordinatorDelegate {

    func navigateToAnotherFlow (withParentFlowCoordinator parentFlowCoordinator: FlowCoordinator, withNextFlowItem nextFlowItem: NextFlowItem) {

        if let nextFlow = nextFlowItem.nextPresentable as? Flow {
            self.coordinate(flow: nextFlow, withStepper: nextFlowItem.nextStepper, withParrentFlowCoordinator: parentFlowCoordinator)
        }
    }

    func willNavigate(to flow: Flow, with step: Step) {
        if !(step is NoStep) {
            self.willNavigateSubject.onNext(("\(flow)", "\(step)"))
        }
    }

    func didNavigate(to flow: Flow, with step: Step) {
        if !(step is NoStep) {
            self.didNavigateSubject.onNext(("\(flow)", "\(step)"))
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
    public var willNavigate: Observable<(String, String)> {
        return self.base.willNavigateSubject.asObservable()
    }

    /// Rx Observable triggered after the Coordinator navigates a Flow/Step
    public var didNavigate: Observable<(String, String)> {
        return self.base.didNavigateSubject.asObservable()
    }
}
