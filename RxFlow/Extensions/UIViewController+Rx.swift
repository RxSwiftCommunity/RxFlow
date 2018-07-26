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

extension Reactive where Base: UIViewController {

    /// Rx observable, triggered when the view has appeared for the first time
    public var firstTimeViewDidAppear: Single<Void> {
        return self.sentMessage(#selector(Base.viewDidAppear)).map { _ in return Void() }.take(1).asSingle()
    }

    /// Rx observable, triggered when the view is being dismissed
    public var dismissed: ControlEvent<Bool> {

        let dismissedSource = self.sentMessage(#selector(Base.viewWillDisappear))
            .filter { [base] _ in base.isBeingDismissed }
            .map { _ in false }

        let movedToParentSource = self.sentMessage(#selector(Base.didMove(toParentViewController:)))
            .filter({!($0.first is UIViewController)})
            .map { _ in false }

        return ControlEvent(events: Observable.merge(dismissedSource, movedToParentSource))
    }

    /// Rx observable, triggered when the view appearance state changes
    public var displayed: Observable<Bool> {
        let viewDidAppearObservable = self.sentMessage(#selector(Base.viewDidAppear)).map { _ in true }
        let viewWillDisappearObservable = self.sentMessage(#selector(Base.viewWillDisappear)).map { _ in false }
        // a UIViewController is at first not displayed
        let initialState = Observable.just(false)
        // future calls to viewDidAppear and viewWillDisappear will chage the displayable state
        return initialState.concat(Observable<Bool>.merge(viewDidAppearObservable, viewWillDisappearObservable))
    }
}
