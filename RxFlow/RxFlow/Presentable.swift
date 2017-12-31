//
//  Presentable.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-25.
//  Copyright © 2017 Warp Factor. All rights reserved.
//

import RxSwift

/// An abstraction of what can present a Loom. For now, UIViewControllers, Warps are Presentable
public protocol Presentable: HasDisposeBag {

    /// Rx Observable that triggers a bool indicating if the current Presentable is being displayed (applies to UIViewController, Warp or UIWindow for instance)
    var rxVisible: Observable<Bool> { get }

    /// Rx Observable (Single trait) triggered when this presentable is displayed for the first time
    var rxFirstTimeVisible: Single<Void> { get }

    /// Rx Observable (Single trait) triggered when this presentable is dismissed
    var rxDismissed: Single<Void> { get }
}
