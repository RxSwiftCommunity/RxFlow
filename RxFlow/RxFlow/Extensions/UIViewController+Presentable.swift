//
//  UIViewController+Presentable.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-25.
//  Copyright © 2017 Warp Factor. All rights reserved.
//

import RxSwift
import UIKit

extension UIViewController: Presentable {

    /// Rx Observable (Single trait) triggered when this UIViewController is displayed for the first time
    public var rxFirstTimeVisible: Single<Void> {
        return self.rx.firstTimeViewDidAppear
    }

    /// Rx Observable that triggers a bool indicating if the current UIViewController is being displayed
    public var rxVisible: Observable<Bool> {
        return self.rx.displayed
    }

    /// Rx Observable (Single trait) triggered when this UIViewController is dismissed
    public var rxDismissed: Single<Void> {
        return self.rx.dismissed.map { _ -> Void in return Void() }.take(1).asSingle()
    }
}
