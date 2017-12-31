//
//  Synchronizable.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-25.
//  Copyright © 2017 Warp Factor. All rights reserved.
//

// this code had been inspired by the project: https://github.com/RxSwiftCommunity/NSObject-Rx
// Its License can be found here: ../DependenciesLicenses/RxSwiftCommunity-NSObject-Rx-License

/// Provides a function to prevent concurrent block execution
public protocol Synchronizable: class {
}

extension Synchronizable {
    func synchronized<T>( _ action: () -> T) -> T {
        objc_sync_enter(self)
        let result = action()
        objc_sync_exit(self)
        return result
    }
}
