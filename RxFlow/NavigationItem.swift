//
//  NavigationItem.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-10-09.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

/// A NavigationItem is the result of the coordination action between a Flow and a Step (See Flow.navigate(to:) function)
/// It describes the next thing that will be presented (a Presentable) and
/// the next thing the Coordinator will listen to have the next navigation Steps (a Stepper).
/// If a navigation action does not have to lead to a NavigationItem, it is possible to have an empty NavigationItem array
public struct NavigationItem {

    /// The presentable that will be handle by the Coordinator. The Coordinator is not
    /// meant to display this presentable, it will only handle its "Display" status
    /// so that the associated Stepper will be listened or not
    let nextPresentable: Presentable

    /// The Stepper that will be handle by the Coordinator. It will emit the new
    /// navigation Steps. The Coordinator will listen to them only if the associated
    /// Presentable is displayed
    let nextStepper: Stepper

    /// Initialize a new NavigationItem
    ///
    /// - Parameters:
    ///   - nextPresentable: the next presentable to be handled by the Coordinator
    ///   - nextStepper: the next Steper to be handled by the Coordinator
    public init(nextPresentable presentable: Presentable, nextStepper stepper: Stepper) {
        self.nextPresentable = presentable
        self.nextStepper = stepper
    }

    /// A empty NavigationItem's array
    public static var noNavigation: [NavigationItem] {
        return []
    }
}
