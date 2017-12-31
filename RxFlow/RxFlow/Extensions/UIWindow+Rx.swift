//
//  UIWindow+Rx.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-10-01.
//  Copyright © 2017 Warp Factor. All rights reserved.
//

import UIKit
import RxSwift

extension Reactive where Base: UIWindow {

    /// Rx Single that is triggered once the UIWindow is displayed
    public var windowDidAppear: Single<Void> {
        return self.sentMessage(#selector(Base.makeKeyAndVisible)).map {_ in return Void()}.take(1).asSingle()
    }

}
