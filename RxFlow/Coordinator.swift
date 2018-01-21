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
    func didNavigate (to flow: Flow, with step: Step)
}

/// A FlowCoordinator handles the navigation inside a dedicated Flow
/// It will listen for Steps emitted be the Flow's Stepper companion or
/// the Steppers produced by the Flow.navigate(to:) function along the way
class FlowCoordinator {

    /// The Flow to be coordinated
    private let flow: Flow

    /// The Rx subject that holds all the Steps trigerred either by the Flow's Stepper
    /// or by the Steppers produced by the Flow.navigate(to:) function
    private let steps = PublishSubject<Step>()

    /// The delegate allows the FlowCoordinator to communicate with the Coordinator
    /// in the case of a new Flow to coordinate or before and after a navigation action
    private weak var delegate: FlowCoordinatorDelegate!

    internal let disposeBag = DisposeBag()

    /// Initialize a FlowCoordinator
    ///
    /// - Parameter flow: The Flow to coordinate
    init(for flow: Flow, withDelegate delegate: FlowCoordinatorDelegate) {
        self.flow = flow
        self.delegate = delegate
    }

    /// Launch the coordination process
    ///
    /// - Parameter stepper: The Stepper that goes with the Flow. It will trigger some Steps at the Flow level
    func coordinate (listeningTo stepper: Stepper) {

        // Steps can be emitted by the Stepper companion of the Flow or the Steppers in the NextFlowItems fired by the Flow.navigate(to:) function
        self.steps.asObservable().subscribe(onNext: { [unowned self] (step) in

            // a new Step has been triggered for this Flow. Let's navigate it and see what NextFlowItems come from that
            self.delegate.willNavigate(to: self.flow, with: step)
            let nextFlowItems = self.flow.navigate(to: step)
            self.delegate.didNavigate(to: self.flow, with: step)

            // when first presentable is discovered we can assume the Flow is ready to be used (its root can be used in other Flows)
            self.flow.flowReadySubject.onNext(true)

            // we know which NextFlowItems have been produced by this navigation action
            // each one of these NextFlowItems will lead to other navigation actions (for example, new Flows to handle and new Steppers to listen)
            nextFlowItems.forEach({ [unowned self] (nextFlowItem) in

                // if the NextFlowItems's next presentable represents a Flow, it has to be processed at a higher level because
                // the FlowCoordinator only knowns about the Flow it's in charge of.
                // The FlowCoordinator will expose through its delegate
                if nextFlowItem.nextPresentable is Flow {
                    self.delegate.navigateToAnotherFlow(withNextFlowItem: nextFlowItem)
                } else {
                    // the NextFlowItem's next presentable is not a Flow, it can be processed at the FlowCoordinator level

                    // we have to wait for the Presentable to be displayed at least once to be able to
                    // listen to the Stepper. Indeed, we do not want to emit other navigation actions
                    // until there is a first ViewController in the hierarchy
                    let nextPresentable = nextFlowItem.nextPresentable
                    let nextStepper = nextFlowItem.nextStepper
                    nextPresentable.rxFirstTimeVisible.subscribe(onSuccess: { [unowned self, unowned nextPresentable, unowned nextStepper] (_) in

                        // we listen to the Presentable's Stepper. For each new Step value, we trigger a new navigation process
                        // this is the core principle of the whole mechanism.
                        // The process is paused each time the Presntable is not currently displayed,
                        // for instance when another Presentable is on top of it in the ViewControllers hierarchy.
                        nextStepper.steps
                            .pausable(nextPresentable.rxVisible.startWith(true))
                            .asDriver(onErrorJustReturn: NoStep()).drive(onNext: { [unowned self] (step) in
                                // the nextPresentable's Stepper fires a new Step
                                self.steps.onNext(step)
                            }).disposed(by: nextPresentable.disposeBag)

                    }).disposed(by: self.disposeBag)
                }
            })
        }).disposed(by: self.disposeBag)

        // we listen for the Warp dedicated Weftable
        stepper.steps.pausable(self.flow.rxVisible.startWith(true)).asDriver(onErrorJustReturn: NoStep()).drive(onNext: { [unowned self] (step) in
            // the Flow's Stepper fires a new Step (the initial Step for exemple)
            self.steps.onNext(step)
        }).disposed(by: flow.disposeBag)

    }
}

/// The only purpose of a Coordinator is to handle the navigation that is
/// declared in the Flows of the application.
final public class Coordinator {

    private var flowCoordinators = [FlowCoordinator]()
    private let disposeBag = DisposeBag()
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
        let flowCoordinator = FlowCoordinator(for: flow, withDelegate: self)

        // we stack the FlowCoordinators so that we do not lose there reference (whereas it could be a leak)
        self.flowCoordinators.append(flowCoordinator)

        // let's coordinate the Flow
        flowCoordinator.coordinate(listeningTo: stepper)

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
