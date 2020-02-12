//
//  FlowCoordinatorTests.swift
//  RxFlowTests
//
//  Created by Thibault Wittemberg on 2019-02-02.
//  Copyright © 2019 RxSwiftCommunity. All rights reserved.
//

@testable import RxFlow
import XCTest
import RxBlocking
import RxSwift
import RxTest

enum TestSteps: Step {
    case one
    case two
    case multiple
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
        case .multiple:
            return .multiple(
                flowContributors: [
                    .contribute(withNextPresentable: PresentableNeverDismissed(), withNextStepper: OneStepper(withSingleStep: TestSteps.two)),
                    .forwardToCurrentFlow(withStep: TestSteps.one)
                ]
            )
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
}
