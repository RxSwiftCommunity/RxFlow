//
//  UIViewController+Rx.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-25.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

// this code had been inspired by the project: https://github.com/devxoul/RxViewController
// Its License can be found here: ../DependenciesLicenses/devxoul-RxViewController-License
#if canImport(UIKit)
import UIKit.UIViewController
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {

    /// Rx observable, triggered when the view is being dismissed
    public var dismissed: ControlEvent<Bool> {

        let dismissedSource = self.sentMessage(#selector(Base.viewDidDisappear))
            .filter { [base] _ in base.isBeingDismissed }
            .map { _ in false }

        let movedToParentSource = self.sentMessage(#selector(Base.didMove))
            .filter({!($0.first is UIViewController)})
            .map { _ in false }

        return ControlEvent(events: Observable.merge(dismissedSource, movedToParentSource))
    }

    /// Rx observable, triggered when the view appearance state changes
    public var displayed: Observable<Bool> {
        let viewDidAppearObservable = self.sentMessage(#selector(Base.viewDidAppear)).map { _ in true }
        let viewDidDisappearObservable = self.sentMessage(#selector(Base.viewDidDisappear)).map { _ in false }
        // a UIViewController is at first not displayed
        let initialState = Observable.just(false)
        // future calls to viewDidAppear and viewDidDisappear will change the displayable state
        return initialState.concat(Observable<Bool>.merge(viewDidAppearObservable, viewDidDisappearObservable))
    }
}

#endif
