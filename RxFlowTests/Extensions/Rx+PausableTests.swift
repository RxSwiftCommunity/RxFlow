//
//  Rx+PausableTests.swift
//  RxFlowTests
//
//  Created by Thibault Wittemberg on 2018-10-21.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//
@testable import RxFlow
import XCTest
import RxSwift
import RxBlocking

final class Rx_PausableTests: XCTestCase {

    func testPausable() throws {
        // Given: a sequence emitting 10 integers and a pauser that pauses this sequence each time the value is odd
        let emitter = Observable<Int>.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        let pauserSubject = BehaviorSubject<Bool>(value: false)

        // When: executing the sequence
        let values = try emitter
            .takeUntil(self.rx.deallocated)
            .do(onNext: { (value) in
                pauserSubject.onNext((value % 2) == 0)
            })
            .pausable(withPauser: pauserSubject)
            .toBlocking().toArray()

        // Then: the pauser has paused the sequence each time the value was odd
        XCTAssertEqual(values, [2, 4, 6, 8, 10])
    }

    func testPausableAfterCount() throws {
        // Given: a sequence emitting 10 integers and a pauser that pauses this sequence each time the value is odd
        let emitter = Observable<Int>.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        let pauserSubject = BehaviorSubject<Bool>(value: false)

        // When: executing the sequence
        let values = try emitter
            .takeUntil(self.rx.deallocated)
            .do(onNext: { (value) in
                pauserSubject.onNext((value % 2) == 0)
            })
            .pausable(afterCount: 6, withPauser: pauserSubject)
            .toBlocking().toArray()

        // Then: the pauser has begun to pause the sequence only after 6 first values and
        // then paused the sequence each time the value was odd
        XCTAssertEqual(values, [1, 2, 3, 4, 5, 6, 8, 10])
    }
}
