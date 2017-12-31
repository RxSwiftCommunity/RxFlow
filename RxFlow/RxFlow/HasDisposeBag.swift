//
//  HasDisposeBag.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-25.
//  Copyright © 2017 Warp Factor. All rights reserved.
//

// this code had been inspired by the project: https://github.com/RxSwiftCommunity/NSObject-Rx
// Its License can be found here: ../DependenciesLicenses/RxSwiftCommunity-NSObject-Rx-License

import RxSwift

private var disposeBagContext: UInt8 = 0

/// Each HasDisposeBag offers a unique Rx DisposeBag instance
public protocol HasDisposeBag: Synchronizable {

    /// a unique Rx DisposeBag instance
    var disposeBag: DisposeBag { get }
}

extension HasDisposeBag {

    /// The concrete DisposeBag instance
    public var disposeBag: DisposeBag {
        return self.synchronized {
            if let disposeObject = objc_getAssociatedObject(self, &disposeBagContext) as? DisposeBag {
                return disposeObject
            }
            let disposeObject = DisposeBag()
            objc_setAssociatedObject(self, &disposeBagContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return disposeObject
        }
    }
}
