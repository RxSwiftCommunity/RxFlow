//
//  Flowable.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-10-09.
//  Copyright © 2017 Warp Factor. All rights reserved.
//

/// A Flowable is the result of the coordination action between a Flow and a Step (See Flow.navigate(to:) function)
/// It describes the next thing that will be presented (a Presentable) and
/// the next thing the Coordinator will listen to have the next navigation Steps (a Stepper).
/// If a navigation action does not have to lead to a Flowable, it is possible to have an empty Flowable array
public struct Flowable {

    /// The presentable that will be handle by the Coordinator. The Coordinator is not
    /// meant to display this presentable, it will only handle its "Display" status
    /// so that the associated Stepper will be listened or not
    var nextPresentable: Presentable?

    /// The Stepper that will be handle by the Coordinator. It will emit the new
    /// navigation Steps. The Coordinator will listen to them only if the associated
    /// Presentable is displayed
    var nextStepper: Stepper?

    /// Initialize a new Flowable
    ///
    /// - Parameters:
    ///   - nextPresentable: the next presentable to be handled by the Coordinator
    ///   - nextStepper: the next Steper to be handled by the Coordinator
    public init(nextPresentable presentable: Presentable? = nil, nextStepper stepper: Stepper? = nil) {
        self.nextPresentable = presentable
        self.nextStepper = stepper
    }

    /// An empty Flowable that won't be taken care of by the Coordinator
    public static var empty: Flowable {
        return Flowable()
    }

    /// A empty Flowable's array
    public static var noFlow: [Flowable] {
        return [Flowable.empty]
    }
}
