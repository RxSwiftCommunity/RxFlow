//
//  UIViewController+PresentableTests.swift
//  RxFlowTests
//
//  Created by Thibault Wittemberg on 2018-10-28.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

#if canImport(UIKit)

@testable import RxFlow
import XCTest
import RxBlocking
import RxSwift
import RxTest

final class UIViewController_PresentableTests: XCTestCase {

    func testUIViewControllerVisible() {
        // Given: a UIViewController
        let viewController = TestUIViewController()
        let testScheduler = TestScheduler(initialClock: 0)
        let observer = testScheduler.createObserver(Bool.self)
        testScheduler.start()
        _ = viewController.rxVisible.asObservable().take(until: self.rx.deallocating).bind(to: observer)

        // When: Displaying/Hiding it 3 times
        viewController.viewDidAppear(false)
        viewController.viewDidDisappear(false)
        viewController.viewDidAppear(false)
        viewController.viewDidDisappear(false)
        viewController.viewDidAppear(false)
        viewController.viewDidDisappear(false)

        // Then: rxVisible is emitted 6 times + 1 time false before being visible
        let referenceVisible = [false, true, false, true, false, true, false]
        XCTAssertEqual(observer.events.count, 7)
        var index = 0
        referenceVisible.forEach {
            XCTAssertEqual(observer.events[index].value.element, $0)
            index += 1
        }
    }

    func testUIViewControllerVisibleStartsVisible() {
        // Given: a UIViewController that starts "displayed"
        let window = UIWindow()
        let viewController = TestUIViewController()
        _ = viewController.view
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        let testScheduler = TestScheduler(initialClock: 0)
        let observer = testScheduler.createObserver(Bool.self)
        testScheduler.start()

        // When: subscribing to rxVisible
        _ = viewController.rxVisible.asObservable().take(until: self.rx.deallocating).bind(to: observer)

        // Then: rxVisible emits the first value as true
        let referenceVisible = [true]
        XCTAssertEqual(observer.events.count, 1)
        var index = 0
        referenceVisible.forEach {
            XCTAssertEqual(observer.events[index].value.element, $0)
            index += 1
        }
    }

    func testUIViewControllerDismissed() {
        // Given: a UIViewController
        let viewController = TestUIViewController()
        let testScheduler = TestScheduler(initialClock: 0)
        let observer = testScheduler.createObserver(Void.self)
        testScheduler.start()
        _ = viewController.rxDismissed.asObservable().take(until: self.rx.deallocating).bind(to: observer)

        // When: Dismissing the ViewController
        viewController.didMove(toParent: nil)

        // Then: rxDismissed event is emitted + completed
        XCTAssertEqual(observer.events.count, 2)
    }
}

#endif
