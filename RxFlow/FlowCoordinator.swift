//
//  FlowCoordinator.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 2018-12-19.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

#if canImport(UIKit)
import Foundation
import RxCocoa
import RxSwift

/// A FlowCoordinator handles the navigation of a Flow, based on its Stepper and the FlowContributors it emits
public final class FlowCoordinator: NSObject {
    private let disposeBag = DisposeBag()

    // FlowCoordinator relations (father/children)
    private var childFlowCoordinators = [String: FlowCoordinator]()
    private weak var parentFlowCoordinator: FlowCoordinator? {
        didSet {
            if let parentFlowCoordinator = self.parentFlowCoordinator {
                self.willNavigateRelay.bind(to: parentFlowCoordinator.willNavigateRelay).disposed(by: self.disposeBag)
                self.didNavigateRelay.bind(to: parentFlowCoordinator.didNavigateRelay).disposed(by: self.disposeBag)
            }
        }
    }

    // Rx PublishRelays to handle steps and navigation triggering
    private let stepsRelay = PublishRelay<Step>()
    fileprivate let willNavigateRelay = PublishRelay<(Flow, Step)>()
    fileprivate let didNavigateRelay = PublishRelay<(Flow, Step)>()

    // FlowCoordinator unique identifier
    internal let identifier = UUID().uuidString

    /// Execute the navigation of the Flow
    ///
    /// - Parameters:
    ///   - flow: the Flow that describes the navigation we want to coordinate
    ///   - stepper: the Stepper that drives the global navigation of the Flow
    // swiftlint:disable function_body_length
    public func coordinate (flow: Flow, with stepper: Stepper = DefaultStepper()) {
        // listen for the internal steps relay that aggregates the flow's Stepper's steps and
        // the FlowContributors's Stepper's steps
        self.stepsRelay
            .takeUntil(flow.parentPresentable?.rxDismissed.asObservable() ?? flow.rxDismissed.asObservable())
            .do(onDispose: { [weak self] in
                self?.childFlowCoordinators.removeAll()
                self?.parentFlowCoordinator?.childFlowCoordinators.removeValue(forKey: self?.identifier ?? "")
            })
            .asSignal(onErrorJustReturn: NoneStep())
            .flatMapLatest { flow.adapt(step: $0).asSignal(onErrorJustReturn: NoneStep()) }
            .do(onNext: { [weak self] in self?.willNavigateRelay.accept((flow, $0)) })
            .map { return (flowContributors: flow.navigate(to: $0), step: $0) }
            .do(onNext: { [weak self] in self?.didNavigateRelay.accept((flow, $0.step)) })
            .map { $0.flowContributors }
            // performs side effects if the FlowContributors is not about registering a new Stepper or coordinating a new Flow
            .do(onNext: { [weak self] flowContributors in
                switch flowContributors {
                case let .one(flowContributor):
                    self?.performSideEffects(with: flowContributor)
                case .triggerParentFlow(let withStep):
                    self?.parentFlowCoordinator?.stepsRelay.accept(withStep)
                case .end(let forwardToParentFlowWithStep):
                    self?.parentFlowCoordinator?.stepsRelay.accept(forwardToParentFlowWithStep)
                    self?.childFlowCoordinators.removeAll()
                    self?.parentFlowCoordinator?.childFlowCoordinators.removeValue(forKey: self?.identifier ?? "")
                case let .multiple(childFlowContributors):
                    childFlowContributors.forEach { self?.performSideEffects(with: $0) }
                case .none:
                    break
                }
            })
            .map { [weak self] in self?.nextPresentablesAndSteppers(from: $0) ?? [] }
            // the readiness of the flow depends either on the readiness of subflows, or is set to true
            .do(onNext: { [weak self] presentableAndSteppers in
                self?.setReadiness(for: flow, basedOn: presentableAndSteppers.map { $0.presentable })
            })
            // transforms a FlowContributors in a sequence of individual FlowContributor
            .flatMap { Signal.from($0) }
            // the FlowContributor is related to a new Flow, we coordinate this new Flow
            .do(onNext: { [weak self] presentableAndStepper in
                if let childFlow = presentableAndStepper.presentable as? Flow {
                    let childFlowCoordinator = FlowCoordinator()
                    childFlowCoordinator.parentFlowCoordinator = self
                    self?.childFlowCoordinators[childFlowCoordinator.identifier] = childFlowCoordinator
                    childFlowCoordinator.coordinate(flow: childFlow, with: presentableAndStepper.stepper)
                }
            })
            .filter { !($0.presentable is Flow) }
            // the FlowContributor is not related to a new Flow but to a Presentable/Stepper
            // this new Stepper will contribute to the current Flow.
            .flatMap { [weak self] in self?.steps(from: $0, within: flow) ?? Signal.empty() }
            .emit(to: self.stepsRelay)
            .disposed(by: self.disposeBag)

        // listen for the Flow's dedicated Stepper. It will drive the global flow navigation
        stepper.steps
            .do(onSubscribed: { stepper.readyToEmitSteps() })
            .startWith(stepper.initialStep)
            .filter { !($0 is NoneStep) }
            .takeUntil(flow.parentPresentable?.rxDismissed.asObservable() ?? flow.rxDismissed.asObservable())
            // for now commenting this line to allow a Stepper trigger "dismissing" steps
            // even if a flow is displayed on top of it
            // .pausable(afterCount: 1, withPauser: flow.rxVisible)
            .bind(to: self.stepsRelay)
            .disposed(by: self.disposeBag)
    }

    /// allow to drive the navigation from the outside of a flow
    /// - Parameter step: the step to navigate to. (it will be passed to all sub flows)
    public func navigate(to step: Step) {
        self.stepsRelay.accept(step)
        self.childFlowCoordinators.values.forEach { $0.navigate(to: step) }
    }

    private func performSideEffects(with flowContributor: FlowContributor) {
        switch flowContributor {
        case let .forwardToCurrentFlow(step):
            stepsRelay.accept(step)
        case let .forwardToParentFlow(step):
            parentFlowCoordinator?.stepsRelay.accept(step)
        case .contribute:
            break
        }
    }

    /// transforms a FlowContributors in the sequence of individual FlowContributor
    /// returns Signal.empty if the inner FlowContributor is not about Presentable/Stepper
    ///
    /// - Parameter flowContributors: the flowContributors to transform
    /// - Returns: the sequence of individual FlowContributor embedded in the flowContributors
    private func nextPresentablesAndSteppers(from flowContributors: FlowContributors) -> [PresentableAndStepper] {
        switch flowContributors {
        case .none, .triggerParentFlow, .one(.forwardToCurrentFlow), .one(.forwardToParentFlow), .end:
            return []
        case let .one(.contribute(nextPresentable, nextStepper, allowStepWhenNotPresented)):
            return [PresentableAndStepper(presentable: nextPresentable,
                                          stepper: nextStepper,
                                          allowStepWhenNotPresented: allowStepWhenNotPresented)]
        case .multiple(let flowContributors):
            return flowContributors.compactMap { flowContributor -> PresentableAndStepper? in
                if case let .contribute(nextPresentable, nextStepper, allowStepWhenNotPresented) = flowContributor {
                    return PresentableAndStepper(presentable: nextPresentable,
                                                 stepper: nextStepper,
                                                 allowStepWhenNotPresented: allowStepWhenNotPresented)
                }

                return nil
            }
        }
    }

    /// retrieve Steps from the combination presentable/stepper
    ///
    /// - Parameter nextPresentableAndStepper: the combination presentable/stepper that will generate new Steps
    /// - Parameter flow: the Flow in which the stepper emits new steps
    /// - Returns: the reactive sequence of Steps from the combination presentable/stepper
    private func steps (from nextPresentableAndStepper: PresentableAndStepper, within flow: Flow) -> Signal<Step> {
        var stepStream = nextPresentableAndStepper
            .stepper
            .steps
            .do(onSubscribed: { nextPresentableAndStepper.stepper.readyToEmitSteps() })
            .startWith(nextPresentableAndStepper.stepper.initialStep)
            .filter { !($0 is NoneStep) }
            .takeUntil(nextPresentableAndStepper.presentable.rxDismissed.asObservable())

        // by default we cannot accept steps from a presentable that is not visible
        if nextPresentableAndStepper.allowStepWhenNotPresented == false {
            stepStream = stepStream.pausable(withPauser: nextPresentableAndStepper.presentable.rxVisible)
        }

        return stepStream.asSignal(onErrorJustReturn: NoneStep())
    }

    /// sets the readiness of the flow based on either its subflows's readiness or directly to true if no subflows
    ///
    /// - Parameters:
    ///   - flow: the flow we're setting the readiness
    ///   - presentableAndSteppers: the presentables
    // swiftlint:disable force_cast
    private func setReadiness (for flow: Flow, basedOn presentables: [Presentable]) {
        let flowReadySingles = presentables
            .filter { $0 is Flow }
            .map { $0 as! Flow }
            .map { $0.rxFlowReady }

        if flowReadySingles.isEmpty {
            flow.flowReadySubject.accept(true)
        } else {
            _ = Single<Bool>.zip(flowReadySingles)
                .map { _ in return true }
                .asObservable()
                .take(1)
                .bind(to: flow.flowReadySubject)
        }
    }
}

// MARK: - FlowCoordinator Reactive extensions
public extension Reactive where Base: FlowCoordinator {
    /// Rx Observable emitted before the navigation to a Step within a Flow
    var willNavigate: Observable<(Flow, Step)> {
        return self.base.willNavigateRelay.asObservable()
    }

    /// Rx Observable emitted after the navigation to a Step within a Flow
    var didNavigate: Observable<(Flow, Step)> {
        return self.base.didNavigateRelay.asObservable()
    }
}

/// Inner class that combines a Presentable and a Stepper to produce new Steps
private class PresentableAndStepper {
    fileprivate let presentable: Presentable
    fileprivate let stepper: Stepper
    fileprivate let allowStepWhenNotPresented: Bool

    init(presentable: Presentable, stepper: Stepper, allowStepWhenNotPresented: Bool) {
        self.presentable = presentable
        self.stepper = stepper
        self.allowStepWhenNotPresented = allowStepWhenNotPresented
    }
}

#endif
