//
//  FlowCoordinatorTests.swift
//  RxFlowTests
//
//  Created by Thibault Wittemberg on 2019-02-02.
//  Copyright © 2019 RxSwiftCommunity. All rights reserved.
//

#if canImport(UIKit)

import Dispatch
@testable import RxFlow
import XCTest
import RxBlocking
import RxSwift
import RxCocoa
import RxTest

enum TestSteps: Step {
    case one
    case two
    case three
    case multiple
    case unauthorized
}

final class TestOneAndMultipleFlowCoordinatorFlow: Flow {
    final private class PresentableNeverDismissed: Presentable {
        let rxVisible = Observable.just(true)

        let rxDismissed = Single<Void>.never()
    }

    private let rootViewController = TestUIViewController()
    let recordedSteps = ReplaySubject<TestSteps>.create(bufferSize: 10)
    var stepOneCalled = false

    var root: Presentable {
        return self.rootViewController
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? TestSteps else { return .none }
        recordedSteps.onNext(step)
        switch step {
        case .one:
            stepOneCalled = true
            return .none
        case .two:
            return .none
        case .three:
            return .none
        case .multiple:
            return .multiple(
                flowContributors: [
                    .contribute(withNextPresentable: PresentableNeverDismissed(), withNextStepper: OneStepper(withSingleStep: TestSteps.two)),
                    .forwardToCurrentFlow(withStep: TestSteps.one)
                ]
            )
        case .unauthorized:
            return .none
        }
    }
}

final class TestAllowStepWhenPresentableNotPresentedFlow: Flow {
    final private class PresentableNotDisplayed: Presentable {
        let rxVisible = Observable.just(false)

        let rxDismissed = Single<Void>.never()
    }

    private let rootViewController = TestUIViewController()
    let recordedSteps = ReplaySubject<TestSteps>.create(bufferSize: 10)

    var root: Presentable {
        return self.rootViewController
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? TestSteps else { return .none }
        recordedSteps.onNext(step)

        switch step {
        case .one:
            return .one(flowContributor: .contribute(withNextPresentable: PresentableNotDisplayed(),
                                                     withNextStepper: OneStepper(withSingleStep: TestSteps.two),
                                                     allowStepWhenNotPresented: true))
        case .two:
            return .none
        default:
            return .none
        }
    }
}

final class TestFilterStepFlow: Flow {
    final private class PresentableNotDisplayed: Presentable {
        let rxVisible = Observable.just(false)

        let rxDismissed = Single<Void>.never()
    }

    private let rootViewController = TestUIViewController()
    private let replacementStepInFilter: TestSteps
    let recordedSteps = ReplaySubject<TestSteps>.create(bufferSize: 10)

    var root: Presentable {
        return self.rootViewController
    }

    init(replacementStepInFilter: TestSteps) {
        self.replacementStepInFilter = replacementStepInFilter
    }

    func adapt(step: Step) -> Single<Step> {
        switch step {
        case TestSteps.one:
            return .just(self.replacementStepInFilter)
        default:
            return .just(step)
        }
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? TestSteps else { return .none }
        recordedSteps.onNext(step)

        switch step {
        case .two:
            return .one(flowContributor: .contribute(withNextPresentable: PresentableNotDisplayed(),
                                                     withNextStepper: OneStepper(withSingleStep: TestSteps.one),
                                                     allowStepWhenNotPresented: true))
        default:
            return .none
        }
    }
}

final class TestDeepLinkFlow: Flow {
    private let rootViewController = TestUIViewController()

    var root: Presentable {
        return self.rootViewController
    }

    private let recordedSteps: ReplaySubject<TestSteps>

    init(recordedSteps: ReplaySubject<TestSteps>) {
        self.recordedSteps = recordedSteps
    }

    func navigate(to step: Step) -> FlowContributors {

        guard let step = step as? TestSteps else { return .none }

        switch step {
        case .one:
            return .multiple(flowContributors: [
                .contribute(withNextPresentable: TestDeepLinkFlow(recordedSteps: self.recordedSteps),
                            withNextStepper: OneStepper(withSingleStep: TestSteps.two)),
                .contribute(withNextPresentable: TestDeepLinkFlow(recordedSteps: self.recordedSteps),
                            withNextStepper: OneStepper(withSingleStep: TestSteps.two))
            ])
        case .three:
            recordedSteps.onNext(step)
            return .none
        default:
            return .none
        }
    }
}

final class TestDismissedFlow: Flow {
    final private class PresentableWillDismiss: UIViewController {
        let rxVisible = Observable.just(false)

        let rxDismissed: Single<Void>

        init(rxDismissed: Single<Void>) {
            self.rxDismissed = rxDismissed
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    var root: Presentable {
        rootViewController
    }

    private let rootViewController: Presentable

    let recordedSteps = ReplaySubject<TestSteps>.create(bufferSize: 10)

    let rxDismissedRelay = PublishSubject<Void>()

    init() {
        rootViewController = PresentableWillDismiss(rxDismissed: rxDismissedRelay.asSingle())
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? TestSteps else { return .none }
        recordedSteps.onNext(step)
        return .none
    }
}

final class TestLeakingFlow: Flow {
    var root: Presentable = UIViewController()

    var rxDismissed: Single<Void> { rxDismissedRelay.take(1).asSingle() }
    let rxDismissedRelay = PublishRelay<Void>()

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? TestSteps else { return .none }

        switch step {
        case .one:
            let flowContributor = FlowContributor.contribute(
                withNextPresentable: UIViewController(),
                withNextStepper: DefaultStepper()
            )
            return .one(flowContributor: flowContributor)
        default:
            return .none
        }
    }
}

final class TestChildLeakingFlow: Flow {
    final class ChildViewController: UIViewController {
        var onDeinit: (() -> Void)? = nil
        
        deinit {
            onDeinit?()
        }
    }
    
    var root: Presentable = UIViewController()
    weak var childViewController: ChildViewController? = nil
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? TestSteps else { return .none }

        switch step {
        case .one:
            let viewController = ChildViewController()
            childViewController = viewController
            let flowContributor = FlowContributor.contribute(
                withNextPresentable: viewController,
                withNextStepper: DefaultStepper()
            )
            return .one(flowContributor: flowContributor)
        default:
            return .none
        }
    }
}

final class FlowCoordinatorTests: XCTestCase {

    func testCoordinateWithOneStepper() {
        // Given: a FlowCoordinator and a Flow
        let flowCoordinator = FlowCoordinator()
        let testFlow = TestOneAndMultipleFlowCoordinatorFlow()

        // When: Coordinating the Flow
        flowCoordinator.coordinate(flow: testFlow, with: OneStepper(withSingleStep: TestSteps.one))

        // Then: The step from the OneStepper is triggered
        XCTAssertEqual(testFlow.stepOneCalled, true)
    }

    func testCoordinateWhenAllowStepWhenNotPresented_doEmitAStep() {
        // Given: a FlowCoordinator and a Flow
        let flowCoordinator = FlowCoordinator()
        let testFlow = TestAllowStepWhenPresentableNotPresentedFlow()

        // When: Coordinating the Flow and returning a FlowContributor that will be listened even
        // if its related presentable is not displayed
        flowCoordinator.coordinate(flow: testFlow, with: OneStepper(withSingleStep: TestSteps.one))

        // Then: The steps are received
        let actualSteps = try? testFlow.recordedSteps.take(2).toBlocking().toArray()
        XCTAssertEqual(actualSteps, [.one, .two])
    }

    func testMultipleSideEffectsPerformed() {
        // Given: a FlowCoordinator and a Flow
        let flowCoordinator = FlowCoordinator()
        let testFlow = TestOneAndMultipleFlowCoordinatorFlow()

        // When: Coordinating the Flow with step triggering multiple FlowContributors
        flowCoordinator.coordinate(flow: testFlow, with: OneStepper(withSingleStep: TestSteps.multiple))

        // Then: Steps from .multiple FlowContributors are triggered.toArray()
        let actualSteps = try? testFlow.recordedSteps.take(3).toBlocking().toArray()
        XCTAssertEqual(actualSteps, [.multiple, .two, .one])
    }

    func testStepHasBeenFilteredBeforeNavigateForAFlowStepper() {
        // Given: a FlowCoordinator and a Flow that replaces a One step by a replacement step
        let flowCoordinator = FlowCoordinator()
        let testFlow = TestFilterStepFlow(replacementStepInFilter: .unauthorized)

        // When: Coordinating the Flow with a OneStepper emitting a One step
        flowCoordinator.coordinate(flow: testFlow, with: OneStepper(withSingleStep: TestSteps.one))

        // Then: The emitted One step is replaced by the replacement step
        let actualStep = try? testFlow.recordedSteps.take(1).toBlocking().toArray()
        XCTAssertEqual(actualStep, [.unauthorized])
    }

    func testStepHasBeenFilteredBeforeNavigateForAPresentableStepper() {
        // Given: a FlowCoordinator and a Flow that replaces a One step by a replacement step
        let flowCoordinator = FlowCoordinator()
        let testFlow = TestFilterStepFlow(replacementStepInFilter: .unauthorized)

        // When: Coordinating the Flow with a OneStepper emitting a Two step, and then
        // a presentable emitting a One step
        flowCoordinator.coordinate(flow: testFlow, with: OneStepper(withSingleStep: TestSteps.two))

        // Then: The emitted One step is replaced by the replacement step
        let actualStep = try? testFlow.recordedSteps.take(2).toBlocking().toArray()
        XCTAssertEqual(actualStep, [.two, .unauthorized])
    }

    func testStepIsReceivedInEveryFlowsWhenNavigateToIsCalled() {
        // Given: A Flow with 2 subFlows
        let exp = expectation(description: "Flow when ready")
        let flowCoordinator = FlowCoordinator()
        let recordedSteps = ReplaySubject<TestSteps>.create(bufferSize: 10)
        let deepLinkFlow = TestDeepLinkFlow(recordedSteps: recordedSteps)

        flowCoordinator.coordinate(flow: deepLinkFlow, with: OneStepper(withSingleStep: TestSteps.one))

        // When: the main Flow is ready and we force a navigation
        Flows.use(deepLinkFlow, when: .ready) { (_) in
            flowCoordinator.navigate(to: TestSteps.three)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Then: All the 3 Flows receive the step
        let deepLinkSteps = try? recordedSteps.take(3).toBlocking().toArray()
        XCTAssertEqual(deepLinkSteps, [.three, .three, .three])
    }

    func testStepIsReceivedAfterDismissed() {
        let exp = expectation(description: "Flow when ready")
        let flowCoordinator = FlowCoordinator()
        let dismissedFlow = TestDismissedFlow()

        flowCoordinator.coordinate(flow: dismissedFlow,
                                   with: OneStepper(withSingleStep: TestSteps.one),
                                   allowStepWhenDismissed: true)

        Flows.use(dismissedFlow, when: .created) { (_) in
            // check we will only stop monitoring when parent has dimissed instead of child
            dismissedFlow.rxDismissedRelay.on(.next(()))
            flowCoordinator.navigate(to: TestSteps.two)
            flowCoordinator.navigate(to: TestSteps.three)

            exp.fulfill()
        }

        waitForExpectations(timeout: 1)

        let recordedSteps = try? dismissedFlow.recordedSteps.take(3).toBlocking().toArray()
        XCTAssertEqual(recordedSteps, [.one, .two, .three])
    }

    func testFlowIsNotLeakingWhenHasOneStep() throws {
        weak var leakingFlowReference: TestLeakingFlow?
        let exp = expectation(description: "Flow when ready")
        let flowCoordinator = FlowCoordinator()

        withExtendedLifetime(TestLeakingFlow()) { leakingFlow in
            leakingFlowReference = leakingFlow

            flowCoordinator.coordinate(flow: leakingFlow,
                                       with: OneStepper(withSingleStep: TestSteps.one))

            Flows.use(leakingFlow, when: .created) { (_) in
                exp.fulfill()
            }
        }

        waitForExpectations(timeout: 1)

        XCTAssertNotNil(leakingFlowReference)

        try XCTUnwrap(leakingFlowReference).rxDismissedRelay.accept(Void())

        XCTAssertNil(leakingFlowReference)
    }
    
    func testChildViewControllerIsNotLeakingWhenParentFlowAllowsStepWhenDismissed() throws {
        let exp = expectation(description: "Flow when ready")
        let flowCoordinator = FlowCoordinator()
        let parentFlow = TestChildLeakingFlow()
        
        flowCoordinator.coordinate(flow: parentFlow,
                                   with: OneStepper(withSingleStep: TestSteps.one),
                                   allowStepWhenDismissed: true)
        
        Flows.use(parentFlow, when: .created) { (_) in
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
        
        XCTAssertNotNil(parentFlow.childViewController)
        
        let deallocExp = expectation(description: "Child view controller deallocated")
        parentFlow.childViewController?.onDeinit = { deallocExp.fulfill() }

        try XCTUnwrap(parentFlow.childViewController).didMove(toParent: nil)
        
        waitForExpectations(timeout: 1)
            
        XCTAssertNil(parentFlow.childViewController)
    }

    func testNavigate_executes_on_mainThread() {
        class ThreadRecorderFlow: Flow {
            let rootViewController = UINavigationController()
            var root: Presentable {
                return rootViewController
            }

            var recordedThreadName: String?

            func adapt(step: Step) -> Single<Step> {
                return Single.just(step).observe(on: SerialDispatchQueueScheduler(internalSerialQueueName: UUID().uuidString))
            }

            func navigate(to step: Step) -> FlowContributors {
                self.recordedThreadName = DispatchQueue.currentLabel
                return .none
            }
        }

        let exp = expectation(description: "Navigates on main thread")

        // Given: a Flow that records its navigation thread (and adapt on a background thread)
        let recorderFlow = ThreadRecorderFlow()
        let sut = FlowCoordinator()

        Flows.use(recorderFlow, when: .ready) { (_) in
            exp.fulfill()
        }

        // When: coordinating that flow
        sut.coordinate(flow: recorderFlow,
                       with: OneStepper(withSingleStep: TestSteps.one))

        waitForExpectations(timeout: 0.5)

        // Then: the flow navigates on the main thread
        XCTAssertEqual(recorderFlow.recordedThreadName, "com.apple.main-thread")
    }
}

extension DispatchQueue {
    class var currentLabel: String {
        return String(validatingUTF8: __dispatch_queue_get_label(nil))!
    }
}

#endif
