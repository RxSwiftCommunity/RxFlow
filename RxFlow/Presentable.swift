//
//  Presentable.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-25.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import UIKit.UIViewController

import RxSwift

/// An abstraction of what can be presented to the screen. For now, UIViewControllers and Flows are Presentable
public protocol Presentable {

    /// Rx Observable that triggers a bool indicating if the current Presentable is being displayed
    /// (applies to UIViewController, Warp or UIWindow for instance)
    var rxVisible: Observable<Bool> { get }

    /// Rx Observable (Single trait) triggered when this presentable is dismissed
    var rxDismissed: Single<Void> { get }
}

extension Presentable where Self: UIViewController {

    /// Rx Observable that triggers a bool indicating if the current UIViewController is being displayed
    public var rxVisible: Observable<Bool> {
        return self.rx.displayed
    }

    /// Rx Observable (Single trait) triggered when this UIViewController is dismissed
    public var rxDismissed: Single<Void> {
        return self.rx.dismissed.map { _ -> Void in return Void() }.take(1).asSingle()
    }
}

extension Presentable where Self: Flow {

    /// Rx Observable that triggers a bool indicating if the current Flow is being displayed
    public var rxVisible: Observable<Bool> {
        return self.root.rxVisible
    }

    /// Rx Observable (Single trait) triggered when this Flow is dismissed
    public var rxDismissed: Single<Void> {
        return self.root.rxDismissed
    }
}

extension Presentable where Self: UIWindow {

    /// Rx Observable that triggers a bool indicating if the current UIWindow is being displayed
    public var rxVisible: Observable<Bool> {
        return self.rx.windowDidAppear.asObservable().map { true }
    }

    /// Rx Observable (Single trait) triggered when this UIWindow is dismissed
    public var rxDismissed: Single<Void> {
        return Single.never()
    }
}
