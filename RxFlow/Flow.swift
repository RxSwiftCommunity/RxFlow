//
//  Flow.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-23.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxSwift
import UIKit

private var subjectContext: UInt8 = 0

/// A Flow defines a clear navigation area. Combined to a Step it leads to a navigation action
public protocol Flow: Presentable {

    /// Resolves NextFlowItems according to the Step, in the context of this very Flow
    ///
    /// - Parameters:
    ///   - step: the Step emitted by one of the Steppers declared in the Flow
    /// - Returns: the NextFlowItems matching the Step. These NextFlowItems determines the next navigation steps (Presentables to display / Steppers to listen)
    func navigate (to step: Step) -> NextFlowItems

    /// the Presentable on which rely the navigation inside this Flow. This method must always give the same instance
    var root: Presentable { get }
}

extension Flow {

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

    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flows: Flow(s) to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func whenReady<RootType: UIViewController>(flows: [Flow],
                                                             block: @escaping ([RootType]) -> Void) {
        let flowObservables = flows.map { $0.rxFlowReady.asObservable() }
        let roots = flows.compactMap { $0.root as? RootType }
        guard roots.count == flows.count else {
            fatalError ("Type mismatch, Flows roots types do not match the types awaited in the block")
        }
        _ = Observable<Void>.zip(flowObservables, { (_) in
            return Void()
        }).take(1).subscribe(onNext: { (_) in
            block(roots)
        })
    }

    // swiftlint:disable function_parameter_count
    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: first Flow to be observed
    ///   - flow2: second Flow to be observed
    ///   - flow3: third Flow to be observed
    ///   - flow4: fourth Flow to be observed
    ///   - flow5: fifth Flow to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func whenReady<RootType1: UIViewController,
        RootType2: UIViewController,
        RootType3: UIViewController,
        RootType4: UIViewController,
        RootType5: UIViewController> (flow1: Flow,
                                      flow2: Flow,
                                      flow3: Flow,
                                      flow4: Flow,
                                      flow5: Flow,
                                      block: @escaping (_ flow1Root: RootType1, _ flow2Root: RootType2, _ flow3Root: RootType3, _ flow4Root: RootType4, _ flow5Root: RootType5) -> Void) {
        guard   let root1 = flow1.root as? RootType1,
            let root2 = flow2.root as? RootType2,
            let root3 = flow3.root as? RootType3,
            let root4 = flow4.root as? RootType4,
            let root5 = flow5.root as? RootType5 else {
                fatalError ("Type mismatch, Flows roots types do not match the types awaited in the block")
        }

        _ = Observable<Void>.zip(flow1.rxFlowReady.asObservable(),
                                 flow2.rxFlowReady.asObservable(),
                                 flow3.rxFlowReady.asObservable(),
                                 flow4.rxFlowReady.asObservable(),
                                 flow5.rxFlowReady.asObservable()) { (_, _, _, _, _) in
                                    return Void()
            }.take(1).subscribe(onNext: { (_) in
                block(root1, root2, root3, root4, root5)
            })
    }
    // swiftlint:enable function_parameter_count

    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: first Flow to be observed
    ///   - flow2: second Flow to be observed
    ///   - flow3: third Flow to be observed
    ///   - flow4: fourth Flow to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func whenReady<RootType1: UIViewController,
        RootType2: UIViewController,
        RootType3: UIViewController,
        RootType4: UIViewController> (flow1: Flow,
                                      flow2: Flow,
                                      flow3: Flow,
                                      flow4: Flow,
                                      block: @escaping (_ flow1Root: RootType1, _ flow2Root: RootType2, _ flow3Root: RootType3, _ flow4Root: RootType4) -> Void) {
        guard   let root1 = flow1.root as? RootType1,
                let root2 = flow2.root as? RootType2,
                let root3 = flow3.root as? RootType3,
                let root4 = flow4.root as? RootType4 else {
                fatalError ("Type mismatch, Flows roots types do not match the types awaited in the block")
        }

        _ = Observable<Void>.zip(flow1.rxFlowReady.asObservable(),
                                 flow2.rxFlowReady.asObservable(),
                                 flow3.rxFlowReady.asObservable(),
                                 flow4.rxFlowReady.asObservable()) { (_, _, _, _) in
            return Void()
            }.take(1).subscribe(onNext: { (_) in
                block(root1, root2, root3, root4)
            })
    }

    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: first Flow to be observed
    ///   - flow2: second Flow to be observed
    ///   - flow3: third Flow to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func whenReady<RootType1: UIViewController,
        RootType2: UIViewController,
        RootType3: UIViewController> (flow1: Flow,
                                      flow2: Flow,
                                      flow3: Flow,
                                      block: @escaping (_ flow1Root: RootType1, _ flow2Root: RootType2, _ flow3Root: RootType3) -> Void) {
        guard   let root1 = flow1.root as? RootType1,
                let root2 = flow2.root as? RootType2,
                let root3 = flow3.root as? RootType3 else {
                fatalError ("Type mismatch, Flows roots types do not match the types awaited in the block")
        }

        _ = Observable<Void>.zip(flow1.rxFlowReady.asObservable(),
                                 flow2.rxFlowReady.asObservable(),
                                 flow3.rxFlowReady.asObservable()) { (_, _, _) in
            return Void()
            }.take(1).subscribe(onNext: { (_) in
                block(root1, root2, root3)
            })
    }

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
        guard   let root1 = flow1.root as? RootType1,
                let root2 = flow2.root as? RootType2 else {
                fatalError ("Type mismatch, Flows root types do not match the types awaited in the block")
        }

        _ = Observable<Void>.zip(flow1.rxFlowReady.asObservable(),
                                 flow2.rxFlowReady.asObservable()) { (_, _) in
            return Void()
            }.take(1).subscribe(onNext: { (_) in
                block(root1, root2)
            })
    }

    /// Allow to be triggered only when Flow given as parameters is ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: Flow to be observed
    ///   - block: block to execute whenever the Flow is ready to use
    public static func whenReady<RootType: UIViewController> (flow1: Flow, block: @escaping (_ flowRoot1: RootType) -> Void) {
        guard let root = flow1.root as? RootType else {
            fatalError ("Type mismatch, Flow root type does not match the type awaited in the block")
        }

        _ = flow1.rxFlowReady.subscribe(onSuccess: { (_) in
            block(root)
        })
    }
}
