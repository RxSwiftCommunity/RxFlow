//
//  FlowContributorTests.swift
//  RxFlowTests
//
//  Created by Thibault Wittemberg on 2019-09-01.
//  Copyright © 2019 RxSwiftCommunity. All rights reserved.
//

#if canImport(UIKit)
@testable import RxFlow
import RxRelay
import RxSwift
import XCTest

class MockPresentableAndStepper: Presentable, Stepper {
    let rxVisible = Observable<Bool>.never()
    let rxDismissed = Single<Void>.never()
    let steps = PublishRelay<Step>()
}

final class FlowContributorTests: XCTestCase {

    func testContributeWithNext_returnsContributeWithNextPresentable_andNextStepper() {
        // Given: a single class for Presentable and Stepper
        let nextPresentableAndStepper = MockPresentableAndStepper()

        // When applying FlowContributor.contribute(withNext:)
        let contributor = FlowContributor.contribute(withNext: nextPresentableAndStepper)

        // Then: FlowContributor.contribute(withNext:) is a shortcut to FlowContributor.contribute(nextPresentable:, nextStepper)
        if case let FlowContributor.contribute(nextPresentable, nextStepper, _) = contributor {
            XCTAssert((nextPresentable as! MockPresentableAndStepper) === nextPresentableAndStepper)
            XCTAssert((nextStepper as! MockPresentableAndStepper) === nextPresentableAndStepper)
        } else {
            XCTFail("FlowContributor.contribute(withNext:) should be a shortcut to FlowContributor.contribute(nextPresentable:, nextStepper)")
        }
    }
}
#endif
