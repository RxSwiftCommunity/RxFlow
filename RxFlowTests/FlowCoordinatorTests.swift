//
//  FlowCoordinatorTests.swift
//  RxFlowTests
//
//  Created by Thibault Wittemberg on 2019-02-02.
//  Copyright © 2019 RxSwiftCommunity. All rights reserved.
//

#if canImport(UIKit)

@testable import RxFlow
import XCTest
import RxBlocking
import RxSwift
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

    private let rootViewController = TestUIViewController.instantiate()
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

    private let rootViewController = TestUIViewController.instantiate()
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

    private let rootViewController = TestUIViewController.instantiate()
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
    private let rootViewController = TestUIViewController.instantiate()

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
        XCTAssertEqual(actualSteps, [.multiple, .one, .two])
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
        Flows.whenReady(flow1: deepLinkFlow) { (_) in
            flowCoordinator.navigate(to: TestSteps.three)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Then: All the 3 Flows receive the step
        let deepLinkSteps = try? recordedSteps.take(3).toBlocking().toArray()
        XCTAssertEqual(deepLinkSteps, [.three, .three, .three])
    }
}

#endif
