//
//  FlowCoordinator.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 2018-12-19.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//
import RxSwift
import RxCocoa

@available(*, deprecated, message: "You should use FlowCoordinator")
/// typealias to allow compliance with older versions of RxFlow. Coordinator should be replaced by FlowCoordinator
public typealias Coordinator = FlowCoordinator

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
    public func coordinate (flow: Flow, with stepper: Stepper = DefaultStepper()) {

        // listen for the internal steps relay that aggregates the flow's Stepper's steps and
        // the FlowContributors's Stepper's steps
        self.stepsRelay
            .takeUntil(flow.rxDismissed.asObservable())
            .do(onDispose: { [weak self] in
                self?.childFlowCoordinators.removeAll()
                self?.parentFlowCoordinator?.childFlowCoordinators.removeValue(forKey: self?.identifier ?? "")
            })
            .asSignal(onErrorJustReturn: NoneStep())
            .do(onNext: { [weak self] in self?.willNavigateRelay.accept((flow, $0))})
            .map { return (flowContributors: flow.navigate(to: $0), step: $0) }
            .do(onNext: { [weak self] in self?.didNavigateRelay.accept((flow, $0.step))})
            .do(onNext: { _ in flow.flowReadySubject.accept(true) })
            .map { $0.flowContributors }
            .flatMap { [weak self] flowContributors -> Signal<FlowContributor> in
                switch flowContributors {
                case .none:
                    return Signal.empty()
                case .one(let flowItem):
                    return Signal.just(flowItem)
                case .multiple(let flowItems):
                    return Signal.from(flowItems)
                case .end(let withStepForParentFlow):
                    self?.parentFlowCoordinator?.stepsRelay.accept(withStepForParentFlow)
                    self?.childFlowCoordinators.removeAll()
                    self?.parentFlowCoordinator?.childFlowCoordinators.removeValue(forKey: self?.identifier ?? "")
                    return Signal.empty()
                case .triggerParentFlow(let withStep), .contributeToParentFlow(let withStep):
                    self?.parentFlowCoordinator?.stepsRelay.accept(withStep)
                    return Signal.empty()
                case .contributeToCurrentFlow(let withStep):
                    self?.stepsRelay.accept(withStep)
                    return Signal.empty()
                }
            }
            .do(onNext: { [weak self] flowContributor in
                if let childFlow = flowContributor.nextPresentable as? Flow {
                    let childFlowCoordinator = FlowCoordinator()
                    childFlowCoordinator.parentFlowCoordinator = self
                    self?.childFlowCoordinators[childFlowCoordinator.identifier] = childFlowCoordinator
                    childFlowCoordinator.coordinate(flow: childFlow, with: flowContributor.nextStepper)
                }
            })
            .filter { !($0.nextPresentable is Flow) }
            // from here: we are listening to a Stepper from a Presentable that is not a Flow
            .flatMap { flowContributor -> Signal<Step> in
                return flowContributor
                    .nextStepper
                    .steps
                    .filter { !($0 is NoneStep) }
                    .takeUntil(flowContributor.nextPresentable.rxDismissed.asObservable())
                    .pausable(withPauser: flowContributor.nextPresentable.rxVisible)
                    .asSignal(onErrorJustReturn: NoneStep())
            }
//            .asObservable()
//            .observeOn(SerialDispatchQueueScheduler(qos: .userInitiated))
//            .bind(to: self.stepsRelay)
            .emit(to: self.stepsRelay)
            .disposed(by: self.disposeBag)

        // listen for the Flow's dedicated Stepper. It will drive the global flow navigation
        stepper.steps
            .filter { !($0 is NoneStep) }
            .takeUntil(flow.rxDismissed.asObservable())
            .pausable(afterCount: 1, withPauser: flow.rxVisible)
            .bind(to: self.stepsRelay)
            .disposed(by: self.disposeBag)

        // bootstrap the Flow navigation
        stepper.steps.accept(stepper.initialStep)
    }
}

// MARK: - FlowCoordinator Reactive extensions
public extension Reactive where Base: FlowCoordinator {

    /// Rx Observable emitted before the navigation to a Step within a Flow
    public var willNavigate: Observable<(Flow, Step)> {
        return self.base.willNavigateRelay.asObservable()
    }

    /// Rx Observable emitted after the navigation to a Step within a Flow
    public var didNavigate: Observable<(Flow, Step)> {
        return self.base.didNavigateRelay.asObservable()
    }
}
