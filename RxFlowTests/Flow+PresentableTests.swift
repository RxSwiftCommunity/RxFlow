//
//  Flow+PresentableTests.swift
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

final class TestPresentableFlow: Flow {
    let rootViewController = UIViewController()

    var root: Presentable {
        return self.rootViewController
    }

    func navigate(to step: Step) -> FlowContributors {
        return .none
    }
}

final class Flow_PresentableTests: XCTestCase {

    func testFlowVisible() {
        // Given: a Flow
        let testFlow = TestPresentableFlow()
        let testScheduler = TestScheduler(initialClock: 0)
        let observer = testScheduler.createObserver(Bool.self)
        testScheduler.start()
        _ = testFlow.rxVisible.asObservable().take(until: self.rx.deallocating).bind(to: observer)

        // When: Displaying/Hiding it 3 times
        testFlow.rootViewController.viewDidAppear(false)
        testFlow.rootViewController.viewDidDisappear(false)
        testFlow.rootViewController.viewDidAppear(false)
        testFlow.rootViewController.viewDidDisappear(false)
        testFlow.rootViewController.viewDidAppear(false)
        testFlow.rootViewController.viewDidDisappear(false)

        // Then: rxVisible is emitted 6 times + 1 time false before being visible
        let referenceVisible = [false, true, false, true, false, true, false]
        XCTAssertEqual(observer.events.count, 7)
        var index = 0
        referenceVisible.forEach {
            XCTAssertEqual(observer.events[index].value.element, $0)
            index += 1
        }
    }

    func testFlowDismissed() {
        // Given: a Flow
        let testFlow = TestPresentableFlow()
        let testScheduler = TestScheduler(initialClock: 0)
        let observer = testScheduler.createObserver(Void.self)
        testScheduler.start()
        _ = testFlow.rxDismissed.asObservable().take(until: self.rx.deallocating).bind(to: observer)

        // When: Dismissing the Flow
        testFlow.rootViewController.didMove(toParent: nil)

        // Then: rxDismissed event is emitted + completed
        XCTAssertEqual(observer.events.count, 2)
    }
}

#endif
