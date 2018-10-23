//
//  SyncronizableTests.swift
//  RxFlowTests
//
//  Created by Thibault Wittemberg on 2018-10-21.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import XCTest
@testable import RxFlow

final class SynchronizedClass: Synchronizable {
    let sem: DispatchSemaphore
    let exp: XCTestExpectation

    init(with semaphore: DispatchSemaphore, expectation: XCTestExpectation) {
        self.sem = semaphore
        self.exp = expectation
    }

    func execute () -> Date {
        return self.synchronized { () -> Date in
            _ = self.sem.wait(timeout: .now() + 1)
            self.exp.fulfill()
            return Date()
        }
    }
}

final class SyncronizableTests: XCTestCase {

    func testSynchronize() {
        let exp = expectation(description: "Synchronizable expectations")
        exp.expectedFulfillmentCount = 2
        let sem = DispatchSemaphore(value: 0)
        let concurrentQueue = DispatchQueue(label: "com.rxswiftcommunity.rxflow.concurrentqueue", qos: .userInitiated, attributes: [.concurrent])

        // Given: a synchronizable class
        let synchronizedClass = SynchronizedClass(with: sem, expectation: exp)
        var date1: Date?
        var date2: Date?

        // When: executing concurrent calls to "execute", which is a synchronized function
        concurrentQueue.async {
            date1 = synchronizedClass.execute()
        }

        concurrentQueue.async {
            date2 = synchronizedClass.execute()
        }

        // Then: calls respect the timeline. 
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
                return
            }

            guard let date1 = date1, let date2 = date2 else {
                XCTFail()
                return
            }

            let delta = abs(date2.timeIntervalSince1970 - date1.timeIntervalSince1970)

            guard delta > 1 else {
                XCTFail("Not enough time between 2 executions, delta = \(delta)")
                return
            }
        }

    }
}
