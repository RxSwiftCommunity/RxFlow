//
//  Presentable.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-10-09.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

#if canImport(UIKit)

import RxSwift
import UIKit.UIViewController

/// An abstraction of what can be presented to the screen. For now, UIViewControllers and Flows are Presentable
public protocol Presentable {
    /// Rx Observable that triggers a bool indicating if the current Presentable is being displayed
    /// (applies to UIViewController, Flow or UIWindow for instance)
    var rxVisible: Observable<Bool> { get }

    /// Rx Observable (Single trait) triggered when this presentable is dismissed
    var rxDismissed: Single<Void> { get }
}

public extension Presentable where Self: UIViewController {
    /// Rx Observable that triggers a bool indicating if the current UIViewController is being displayed
    var rxVisible: Observable<Bool> {
        return self.rx.displayed
    }

    /// Rx Observable (Single trait) triggered when this UIViewController is dismissed
    var rxDismissed: Single<Void> {
        return self.rx.dismissed.map { _ -> Void in return Void() }.take(1).asSingle()
    }
}

public extension Presentable where Self: Flow {
    /// Rx Observable that triggers a bool indicating if the current Flow is being displayed
    var rxVisible: Observable<Bool> {
        return self.root.rxVisible
    }

    /// Rx Observable (Single trait) triggered when this Flow is dismissed
    var rxDismissed: Single<Void> {
        return self.root.rxDismissed
    }
}

public extension Presentable where Self: UIWindow {
    /// Rx Observable that triggers a bool indicating if the current UIWindow is being displayed
    var rxVisible: Observable<Bool> {
        return self.rx.windowDidAppear.asObservable().map { true }
    }

    /// Rx Observable (Single trait) triggered when this UIWindow is dismissed
    var rxDismissed: Single<Void> {
        return Single.never()
    }
}

#endif
