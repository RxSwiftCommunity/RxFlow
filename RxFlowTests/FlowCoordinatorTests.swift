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
}

final class TestFlow: Flow {
    private let rootViewController = TestUIViewController.instantiate()
    var stepOneCalled = false

    var root: Presentable {
        return self.rootViewController
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? TestSteps else { return .none }

        switch step {
        case .one:
            stepOneCalled = true
            return .none
        }
    }
}

final class FlowCoordinatorTests: XCTestCase {

    func testCoordinateWithOneStepper() {
        // Given: a FlowCoordinator and a Flow
        let flowCoordinator = FlowCoordinator()
        let testFlow = TestFlow()

        // When: Coordinating the Flow
        flowCoordinator.coordinate(flow: testFlow, with: OneStepper(withSingleStep: TestSteps.one))

        // Then: The step from the OneStepper is triggered
        XCTAssertEqual(testFlow.stepOneCalled, true)
    }
}
