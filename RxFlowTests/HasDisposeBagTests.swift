//
//  HasDisposeBagTests.swift
//  RxFlowTests
//
//  Created by Thibault Wittemberg on 2018-10-15.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import XCTest
import RxFlow

final class HasDisposeBagClass: HasDisposeBag {}

final class HasDisposeBagTests: XCTestCase {

    func testValidDisposeBag() {
        // Given: a class implementing HasDisposeBag
        let hasDisposeBagClass = HasDisposeBagClass()

        // Then: hasDisposeBagClass has a valid DisposeBag, returning always the same instance
        XCTAssertNotNil(hasDisposeBagClass.disposeBag)
        XCTAssert(hasDisposeBagClass.disposeBag === hasDisposeBagClass.disposeBag)
    }
}
