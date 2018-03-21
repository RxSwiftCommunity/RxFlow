//
//  UIWindow+Rx.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-10-01.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import UIKit
import RxSwift

extension Reactive where Base: UIWindow {

    /// Rx Single that is triggered once the UIWindow is displayed
    public var windowDidAppear: Observable<Void> {
        return self.sentMessage(#selector(Base.makeKeyAndVisible)).map {_ in return Void()}
    }

}
