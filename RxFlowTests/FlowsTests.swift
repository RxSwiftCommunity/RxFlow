//
//  FlowsTests.swift
//  RxFlowTests
//
//  Created by Thibault Wittemberg on 2020-01-08.
//  Copyright © 2020 RxSwiftCommunity. All rights reserved.
//

@testable import RxFlow
import UIKit.UIViewController
import XCTest

fileprivate class MockFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController = UIViewController()

    func navigate(to step: Step) -> FlowContributors {
        return .none
    }
}

final class FlowsTests: XCTestCase {

    func test_whenReady_triggers_block_when_one_flow_is_ready() {
        let exp = expectation(description: "WhenReady expectation")
        var isBlockCalled = false

        // Given: a flow which we are waiting for its readiness to trigger a block execution
        let flow = MockFlow()

        Flows.whenReady(flow1: flow) { _ in
            isBlockCalled = true
            exp.fulfill()
        }

        // When: the flow is ready
        flow.flowReadySubject.accept(true)

        waitForExpectations(timeout: 1)

        // Then: the block is executed
        XCTAssertTrue(isBlockCalled)
    }

    func test_whenReady_triggers_block_when_two_flows_are_ready() {
        let exp = expectation(description: "WhenReady expectation")
        var isBlockCalled = false

        // Given: flows which we are waiting for their readiness to trigger a block execution
        let flow1 = MockFlow()
        let flow2 = MockFlow()

        Flows.whenReady(flow1: flow1, flow2: flow2) { (_, _) in
            isBlockCalled = true
            exp.fulfill()
        }

        // When: the flow are ready
        flow1.flowReadySubject.accept(true)
        flow2.flowReadySubject.accept(true)

        waitForExpectations(timeout: 1)

        // Then: the block is executed
        XCTAssertTrue(isBlockCalled)
    }

    func test_whenReady_triggers_block_when_three_flows_are_ready() {
        let exp = expectation(description: "WhenReady expectation")
        var isBlockCalled = false

        // Given: flows which we are waiting for their readiness to trigger a block execution
        let flow1 = MockFlow()
        let flow2 = MockFlow()
        let flow3 = MockFlow()

        Flows.whenReady(flow1: flow1, flow2: flow2, flow3: flow3) { (_, _, _) in
            isBlockCalled = true
            exp.fulfill()
        }

        // When: the flow are ready
        flow1.flowReadySubject.accept(true)
        flow2.flowReadySubject.accept(true)
        flow3.flowReadySubject.accept(true)

        waitForExpectations(timeout: 1)

        // Then: the block is executed
        XCTAssertTrue(isBlockCalled)
    }

    func test_whenReady_triggers_block_when_four_flows_are_ready() {
        let exp = expectation(description: "WhenReady expectation")
        var isBlockCalled = false

        // Given: flows which we are waiting for their readiness to trigger a block execution
        let flow1 = MockFlow()
        let flow2 = MockFlow()
        let flow3 = MockFlow()
        let flow4 = MockFlow()

        Flows.whenReady(flow1: flow1, flow2: flow2, flow3: flow3, flow4: flow4) { (_, _, _, _) in
            isBlockCalled = true
            exp.fulfill()
        }

        // When: the flow are ready
        flow1.flowReadySubject.accept(true)
        flow2.flowReadySubject.accept(true)
        flow3.flowReadySubject.accept(true)
        flow4.flowReadySubject.accept(true)

        waitForExpectations(timeout: 1)

        // Then: the block is executed
        XCTAssertTrue(isBlockCalled)
    }

    func test_whenReady_triggers_block_when_five_flows_are_ready() {
        let exp = expectation(description: "WhenReady expectation")
        var isBlockCalled = false

        // Given: flows which we are waiting for their readiness to trigger a block execution
        let flow1 = MockFlow()
        let flow2 = MockFlow()
        let flow3 = MockFlow()
        let flow4 = MockFlow()
        let flow5 = MockFlow()

        Flows.whenReady(flow1: flow1, flow2: flow2, flow3: flow3, flow4: flow4, flow5: flow5) { (_, _, _, _, _) in
            isBlockCalled = true
            exp.fulfill()
        }

        // When: the flow are ready
        flow1.flowReadySubject.accept(true)
        flow2.flowReadySubject.accept(true)
        flow3.flowReadySubject.accept(true)
        flow4.flowReadySubject.accept(true)
        flow5.flowReadySubject.accept(true)

        waitForExpectations(timeout: 1)

        // Then: the block is executed
        XCTAssertTrue(isBlockCalled)
    }

    func test_whenReady_triggers_block_when_array_of_flows_is_ready() {
        let exp = expectation(description: "WhenReady expectation")
        var isBlockCalled = false

        // Given: an array of flows which we are waiting for their readiness to trigger a block execution
        let flow1 = MockFlow()
        let flow2 = MockFlow()
        let flow3 = MockFlow()
        let flow4 = MockFlow()
        let flow5 = MockFlow()
        let flows = [flow1, flow2, flow3, flow4, flow5]

        Flows.whenReady(flows: flows) { _ in
            isBlockCalled = true
            exp.fulfill()
        }

        // When: the flow are ready
        flow1.flowReadySubject.accept(true)
        flow2.flowReadySubject.accept(true)
        flow3.flowReadySubject.accept(true)
        flow4.flowReadySubject.accept(true)
        flow5.flowReadySubject.accept(true)

        waitForExpectations(timeout: 1)

        // Then: the block is executed
        XCTAssertTrue(isBlockCalled)
    }
}
