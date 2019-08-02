//
//  UIViewController+Rx.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-25.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

// this code had been inspired by the project: https://github.com/devxoul/RxViewController
// Its License can be found here: ../DependenciesLicenses/devxoul-RxViewController-License

import UIKit.UIViewController

import RxSwift
import RxCocoa

extension UIViewController {
    /// If VC is embedded in a parent ViewController then we need to check whether parent is being dismissed.
    fileprivate var isParentBeingDismissed: Bool {
        return self.parent?.isBeingDismissed ?? false
    }
}

extension Reactive where Base: UIViewController {

    /// Rx observable, triggered when the view has appeared for the first time
    public var firstTimeViewDidAppear: Single<Void> {
        return self.sentMessage(#selector(Base.viewDidAppear)).map { _ in return Void() }.take(1).asSingle()
    }

    /// Rx observable, triggered when the view is being dismissed
    public var dismissed: ControlEvent<Bool> {
        let source = self.sentMessage(#selector(Base.viewDidDisappear))
            .filter { _ in self.base.isBeingDismissed || self.base.isParentBeingDismissed }
            .map { _ in false }

        return ControlEvent(events: source)
    }

    /// Rx observable, triggered when the view appearance state changes
    public var displayed: Observable<Bool> {
        let viewDidAppearObservable = self.sentMessage(#selector(Base.viewDidAppear)).map { _ in true }
        let viewWillDisappearObservable = self.sentMessage(#selector(Base.viewWillDisappear)).map { _ in false }
        // a UIViewController is at first not displayed
        let initialState = Observable.just(false)
        // futur calls to viewDidAppear and viewWillDisappear will chage the displayable state
        return initialState.concat(Observable<Bool>.merge(viewDidAppearObservable, viewWillDisappearObservable))
    }
    
    public var popped: Observable<Void> {
        return self.sentMessage(#selector(Base.viewDidDisappear))
            .filter { _ in self.base.isMovingFromParent }
            .map { _ in return Void() }
            .take(1)
    }
}
