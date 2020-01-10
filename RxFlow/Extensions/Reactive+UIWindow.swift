//
//  Reactive+UIWindow.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-10-01.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

#if canImport(UIKit)
import RxSwift
import UIKit.UIWindow

public extension Reactive where Base: UIWindow {
    /// Rx Observable that is triggered once the UIWindow is displayed
    var windowDidAppear: Observable<Void> {
        return self.sentMessage(#selector(Base.makeKeyAndVisible)).map { _ in Void() }
    }
}

#endif
