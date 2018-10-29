//
//  UIViewController+PresentableTests.swift
//  RxFlowTests
//
//  Created by Thibault Wittemberg on 2018-10-28.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

@testable import RxFlow
import XCTest
import RxBlocking
import RxSwift

final class UIViewController_PresentableTests: XCTestCase {

    func testUIViewControllerFirstTimeVisible() {
        let exp = expectation(description: "UIViewController First Time Visible")

        // Given: a UIViewController
        let viewController = TestUIViewController.instantiate()

        // Then: rxFirstTimeVisible is emitted only one time
        _ = viewController.rxFirstTimeVisible.subscribe(onSuccess: { (_) in
            exp.fulfill()
        })

        // When: Displaying/Hiding it several times
        viewController.viewDidAppear(false)
        viewController.viewWillDisappear(false)
        viewController.viewDidAppear(false)
        viewController.viewWillDisappear(false)
        viewController.viewDidAppear(false)

        waitForExpectations(timeout: 1)
    }

    func testUIViewControllerVisible() {
        let exp = expectation(description: "UIViewController Visible")
        let referenceVisible = Observable<Bool>.from([false, true, false, true, false, true, false])
        exp.expectedFulfillmentCount = 7

        // Given: a UIViewController
        let viewController = TestUIViewController.instantiate()

        // Then: rxVisible is emitted 6 times + 1 time false before being visible
        _ = Observable<Bool>.zip(referenceVisible, viewController.rxVisible) { (referenceIsVisible, isVisible) -> Bool in
            return referenceIsVisible == isVisible
            }
            .takeUntil(self.rx.deallocating)
            .subscribe(onNext: { (isValidVisibleState) in
                XCTAssert(isValidVisibleState)
                exp.fulfill()
            })

        // When: Displaying/Hiding it 3 times
        viewController.viewDidAppear(false)
        viewController.viewWillDisappear(false)
        viewController.viewDidAppear(false)
        viewController.viewWillDisappear(false)
        viewController.viewDidAppear(false)
        viewController.viewWillDisappear(false)

        waitForExpectations(timeout: 10)
    }

    func testUIViewControllerDismissed() {
        let exp = expectation(description: "UIViewController Dismissed")

        // Given: a UIViewController
        let viewController = TestUIViewController.instantiate()

        // Then: rxDismissed is emitted
        _ = viewController.rxDismissed.subscribe(onSuccess: { (_) in
            exp.fulfill()
        })

        // When: Dismissing the ViewController
        viewController.didMove(toParent: nil)

        waitForExpectations(timeout: 10)
    }
}
