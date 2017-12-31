//
//  Flow.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-23.
//  Copyright © 2017 Warp Factor. All rights reserved.
//

import RxSwift
import UIKit

private var subjectContext: UInt8 = 0

/// A Flow defines a clear navigation area. Combined to a Step it leads to a navigation action
public protocol Flow: Presentable {

    /// Resolves Flowable according to the Step, in the context of this very Flow
    ///
    /// - Parameters:
    ///   - step: the Step emitted by one of the Steppers declared in the Flow
    /// - Returns: the Flowables matching the Step. This Flowables determines the next navigation steps (Presentables to display / Steppers to listen)
    func navigate (to step: Step) -> [Flowable]

    /// the UIViewController on which rely the navigation inside this Flow. This method must always give the same instance
    var root: UIViewController { get }
}

extension Flow {

    /// Rx Observable that triggers a bool indicating if the current Flow is being displayed
    public var rxVisible: Observable<Bool> {
        return self.root.rxVisible
    }

    /// Rx Observable (Single trait) triggered when this Flow is displayed for the first time
    public var rxFirstTimeVisible: Single<Void> {
        return self.root.rxFirstTimeVisible
    }

    /// Rx Observable (Single trait) triggered when this Flow is dismissed
    public var rxDismissed: Single<Void> {
        return self.root.rxDismissed
    }

    /// Inner/hidden Rx Subject in which we push the "Ready" event
    var flowReadySubject: PublishSubject<Bool> {
        return self.synchronized {
            if let subject = objc_getAssociatedObject(self, &subjectContext) as? PublishSubject<Bool> {
                return subject
            }
            let newSubject = PublishSubject<Bool>()
            objc_setAssociatedObject(self, &subjectContext, newSubject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newSubject
        }

    }

    /// the Rx Obsersable that will be triggered when the first presentable of the Flow is ready to be used
    var rxFlowReady: Single<Bool> {
        return self.flowReadySubject.take(1).asSingle()
    }

}

/// Utility functions to synchronize Flows readyness
public class Flows {

    // swiftlint:disable line_length
    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: first Flow to be observed
    ///   - flow2: second Flow to be observed
    ///   - flow3: third Flow to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func whenReady<RootType1: UIViewController, RootType2: UIViewController, RootType3: UIViewController> (flow1: Flow,
                                                                                                                         flow2: Flow,
                                                                                                                         flow3: Flow,
                                                                                                                         block: @escaping (_ warp1Root: RootType1, _ warp2Root: RootType2, _ warp3Root: RootType3) -> Void) {
        _ = Observable<Void>.zip(flow1.rxFlowReady.asObservable(), flow2.rxFlowReady.asObservable(), flow3.rxFlowReady.asObservable()) { (_, _, _) in
            return Void()
            }.take(1).subscribe(onNext: { (_) in
                guard   let root1 = flow1.root as? RootType1,
                    let root2 = flow2.root as? RootType2,
                    let root3 = flow3.root as? RootType3 else {
                        fatalError ("Type mismatch, Flows roots types do not match the types awaited in the block")
                }
                block(root1, root2, root3)
            })
    }
    // swiftlint:enable line_length

    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: first Flow to be observed
    ///   - flow2: second Flow to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func whenReady<RootType1: UIViewController, RootType2: UIViewController> (flow1: Flow,
                                                                                            flow2: Flow,
                                                                                            block: @escaping (_ flow1Root: RootType1, _ flow2Root: RootType2) -> Void) {
        _ = Observable<Void>.zip(flow1.rxFlowReady.asObservable(), flow2.rxFlowReady.asObservable()) { (_, _) in
            return Void()
            }.take(1).subscribe(onNext: { (_) in
                guard   let root1 = flow1.root as? RootType1,
                    let root2 = flow2.root as? RootType2 else {
                        fatalError ("Type mismatch, Flows root types do not match the types awaited in the block")
                }
                block(root1, root2)
            })
    }

    /// Allow to be triggered only when Flow given as parameters is ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: Flow to be observed
    ///   - block: block to execute whenever the Flow is ready to use
    public static func whenReady<RootType: UIViewController> (flow: Flow, block: @escaping (_ flowRoot: RootType) -> Void) {
        _ = flow.rxFlowReady.subscribe(onSuccess: { (_) in
            guard let root = flow.root as? RootType else {
                fatalError ("Type mismatch, Flow root type does not match the type awaited in the block")
            }
            block(root)
        })
    }
}
