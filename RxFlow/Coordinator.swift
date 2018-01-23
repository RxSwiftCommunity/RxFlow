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

    /// Used to tell the delegate a new Flow is to be coordinated
    ///
    /// - Parameter nextFlowItem: this NextFlowItem taht has a Flow kind of nextPresentable
    func navigateToAnotherFlow (withNextFlowItem nextFlowItem: NextFlowItem)

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

    /// The Flow to be coordinated
    private let flow: Flow

    /// The Stepper that drives the Flow
    /// It will trigger some Steps at the Flow level
    private let stepper: Stepper

    /// The Rx subject that holds all the Steps trigerred either by the Flow's Stepper
    /// or by the Steppers produced by the Flow.navigate(to:) function
    private let steps = PublishSubject<Step>()

    /// The delegate allows the FlowCoordinator to communicate with the Coordinator
    /// in the case of a new Flow to coordinate or before and after a navigation action
    private weak var delegate: FlowCoordinatorDelegate!

    /// Initialize a FlowCoordinator
    ///
    /// - Parameter flow: The Flow to coordinate
    init(for flow: Flow, andStepper stepper: Stepper, withDelegate delegate: FlowCoordinatorDelegate) {
        self.flow = flow
        self.stepper = stepper
        self.delegate = delegate
    }

    /// Launch the coordination process
    ///
    /// - Parameter stepper: The Stepper that goes with the Flow. It will trigger some Steps at the Flow level
    func coordinate () {

        _ = self.steps
            .do(onNext: { [unowned self] (step) in
                // trigger the delegate before the navigation is done
                self.delegate.willNavigate(to: self.flow, with: step)
            })
            .map { [unowned self] (step) -> (Step, [NextFlowItem]) in
                // do the navigation according to the Flow and the Step
                // Retrieve the NextFlowItems
                return (step, self.flow.navigate(to: step))
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
                    self.delegate.navigateToAnotherFlow(withNextFlowItem: nextFlowItem)
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
                self?.steps.onNext(step)
            })

        // we listen for the Warp dedicated Weftable
        self.stepper
            .steps
            .pausable(afterCount: 1, withPauser: self.flow.rxVisible)
            .asDriver(onErrorJustReturn: NoStep())
            .drive(onNext: { [weak self] (step) in
                // the Flow's Stepper fires a new Step (the initial Step for exemple)
                self?.steps.onNext(step)
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

        // a new FlowCoordinator will handle this Flow navigation
        let flowCoordinator = FlowCoordinator(for: flow, andStepper: stepper, withDelegate: self)

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

    func navigateToAnotherFlow (withNextFlowItem nextFlowItem: NextFlowItem) {

        if let nextFlow = nextFlowItem.nextPresentable as? Flow {
            self.coordinate(flow: nextFlow, withStepper: nextFlowItem.nextStepper)
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
