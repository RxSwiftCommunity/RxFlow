//
//  Flow.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-23.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

#if canImport(UIKit)

import RxRelay
import RxSwift
import UIKit

private var subjectContext: UInt8 = 0

/// A Flow defines a clear navigation area. Combined to a Step it leads to a navigation action
public protocol Flow: AnyObject, Presentable, Synchronizable {
    /// the Presentable on which rely the navigation inside this Flow. This method must always give the same instance
    var root: Presentable { get }

    /// Adapts an incoming step before the navigate(to:) function
    /// - Parameter step: the step emitted by a Stepper within the Flow
    /// - Returns: the step (possibly in the future) that should really by interpreted by the navigate(to:) function
    func adapt(step: Step) -> Single<Step>

    /// Resolves FlowContributors according to the Step, in the context of this very Flow
    ///
    /// - Parameters:
    ///   - step: the Step emitted by one of the Steppers declared in the Flow
    /// - Returns: the FlowContributors matching the Step. These FlowContributors determines the next navigation steps (Presentables to
    ///  display / Steppers to listen)
    func navigate(to step: Step) -> FlowContributors
}

public extension Flow {
    func adapt(step: Step) -> Single<Step> {
        return .just(step)
    }
}

extension Flow {
    /// Inner/hidden Rx Subject in which we push the "Ready" event
    internal var flowReadySubject: PublishRelay<Bool> {
        return self.synchronized {
            if let subject = objc_getAssociatedObject(self, &subjectContext) as? PublishRelay<Bool> {
                return subject
            }
            let newSubject = PublishRelay<Bool>()
            objc_setAssociatedObject(self, &subjectContext, newSubject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newSubject
        }
    }

    /// the Rx Obsersable that will be triggered when the first presentable of the Flow is ready to be used
    internal var rxFlowReady: Single<Bool> {
        return self.flowReadySubject.take(1).asSingle()
    }
}

/// Utility functions to synchronize Flows readyness
public enum Flows {
    public enum ExecuteStrategy {
        case ready
        case created
    }

    public static func use<Root: UIViewController>(_ flows: [Flow],
                                                   when strategy: ExecuteStrategy,
                                                   block: @escaping ([Root]) -> Void) {
        let roots = flows.compactMap { $0.root as? Root }
        guard roots.count == flows.count else {
            fatalError("Type mismatch, Flows roots types do not match the types awaited in the block")
        }

        switch strategy {
        case .created:
            block(roots)
        case .ready:
            let flowsReadinesses = flows.map { $0.rxFlowReady }
            _ = Single.zip(flowsReadinesses) { _ in Void() }
                .asDriver(onErrorJustReturn: Void())
                .drive(onNext: { _ in
                    block(roots)
                })
        }
    }

    // swiftlint:disable function_parameter_count
    /// Allow to be triggered etiher when Flows given as parameters are ready to be displayed or right after their instantiation
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: first Flow to be observed
    ///   - flow2: second Flow to be observed
    ///   - flow3: third Flow to be observed
    ///   - flow4: fourth Flow to be observed
    ///   - flow5: fifth Flow to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func use<Root1, Root2, Root3, Root4, Root5>(_ flow1: Flow,
                                                              _ flow2: Flow,
                                                              _ flow3: Flow,
                                                              _ flow4: Flow,
                                                              _ flow5: Flow,
                                                              when strategy: ExecuteStrategy,
                                                              block: @escaping (
        _ flow1Root: Root1,
        _ flow2Root: Root2,
        _ flow3Root: Root3,
        _ flow4Root: Root4,
        _ flow5Root: Root5) -> Void)
        where
        Root1: UIViewController,
        Root2: UIViewController,
        Root3: UIViewController,
        Root4: UIViewController,
        Root5: UIViewController {
            guard
                let root1 = flow1.root as? Root1,
                let root2 = flow2.root as? Root2,
                let root3 = flow3.root as? Root3,
                let root4 = flow4.root as? Root4,
                let root5 = flow5.root as? Root5 else {
                    fatalError("Type mismatch, Flows roots types do not match the types awaited in the block")
            }

            switch strategy {
            case .created:
                block(root1, root2, root3, root4, root5)
            case .ready:
                _ = Single.zip(flow1.rxFlowReady,
                               flow2.rxFlowReady,
                               flow3.rxFlowReady,
                               flow4.rxFlowReady,
                               flow5.rxFlowReady) { _, _, _, _, _ in Void() }
                    .asDriver(onErrorJustReturn: Void())
                    .drive(onNext: { _ in
                        block(root1, root2, root3, root4, root5)
                    })
            }
    }

    // swiftlint:disable function_parameter_count
    /// Allow to be triggered etiher when Flows given as parameters are ready to be displayed or right after their instantiation
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: first Flow to be observed
    ///   - flow2: second Flow to be observed
    ///   - flow3: third Flow to be observed
    ///   - flow4: fourth Flow to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func use<Root1, Root2, Root3, Root4>(_ flow1: Flow,
                                                       _ flow2: Flow,
                                                       _ flow3: Flow,
                                                       _ flow4: Flow,
                                                       when strategy: ExecuteStrategy,
                                                       block: @escaping (
        _ flow1Root: Root1,
        _ flow2Root: Root2,
        _ flow3Root: Root3,
        _ flow4Root: Root4) -> Void) where
        Root1: UIViewController,
        Root2: UIViewController,
        Root3: UIViewController,
        Root4: UIViewController {
            guard
                let root1 = flow1.root as? Root1,
                let root2 = flow2.root as? Root2,
                let root3 = flow3.root as? Root3,
                let root4 = flow4.root as? Root4 else {
                    fatalError("Type mismatch, Flows roots types do not match the types awaited in the block")
            }

            switch strategy {
            case .created:
                block(root1, root2, root3, root4)
            case .ready:
                _ = Single.zip(flow1.rxFlowReady,
                               flow2.rxFlowReady,
                               flow3.rxFlowReady,
                               flow4.rxFlowReady) { _, _, _, _ in Void() }
                    .asDriver(onErrorJustReturn: Void())
                    .drive(onNext: { _ in
                        block(root1, root2, root3, root4)
                    })
            }
    }

    /// Allow to be triggered etiher when Flows given as parameters are ready to be displayed or right after their instantiation
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: first Flow to be observed
    ///   - flow2: second Flow to be observed
    ///   - flow3: third Flow to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func use<Root1, Root2, Root3>(_ flow1: Flow,
                                                _ flow2: Flow,
                                                _ flow3: Flow,
                                                when strategy: ExecuteStrategy,
                                                block: @escaping (
        _ flow1Root: Root1,
        _ flow2Root: Root2,
        _ flow3Root: Root3) -> Void) where
        Root1: UIViewController,
        Root2: UIViewController,
        Root3: UIViewController {
            guard
                let root1 = flow1.root as? Root1,
                let root2 = flow2.root as? Root2,
                let root3 = flow3.root as? Root3 else {
                    fatalError("Type mismatch, Flows roots types do not match the types awaited in the block")
            }

            switch strategy {
            case .created:
                block(root1, root2, root3)
            case .ready:
                _ = Single.zip(flow1.rxFlowReady,
                               flow2.rxFlowReady,
                               flow3.rxFlowReady) { _, _, _ in Void() }
                    .asDriver(onErrorJustReturn: Void())
                    .drive(onNext: { _ in
                        block(root1, root2, root3)
                    })
            }
    }

    /// Allow to be triggered etiher when Flows given as parameters are ready to be displayed or right after their instantiation
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: first Flow to be observed
    ///   - flow2: second Flow to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func use<Root1, Root2>(_ flow1: Flow,
                                         _ flow2: Flow,
                                         when strategy: ExecuteStrategy,
                                         block: @escaping (
        _ flow1Root: Root1,
        _ flow2Root: Root2) -> Void) where
        Root1: UIViewController,
        Root2: UIViewController {
            guard
                let root1 = flow1.root as? Root1,
                let root2 = flow2.root as? Root2 else {
                    fatalError("Type mismatch, Flows roots types do not match the types awaited in the block")
            }

            switch strategy {
            case .created:
                block(root1, root2)
            case .ready:
                _ = Single.zip(flow1.rxFlowReady,
                               flow2.rxFlowReady) { _, _ in Void() }
                    .asDriver(onErrorJustReturn: Void())
                    .drive(onNext: { _ in
                        block(root1, root2)
                    })
            }
    }

    /// Allow to be triggered etiher when Flows given as parameters are ready to be displayed or right after their instantiation
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: first Flow to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func use<Root>(_ flow: Flow,
                                 when strategy: ExecuteStrategy,
                                 block: @escaping (_ flowRoot: Root) -> Void)
        where
        Root: UIViewController {
            guard
                let root = flow.root as? Root else {
                    fatalError("Type mismatch, Flows roots types do not match the types awaited in the block")
            }

            switch strategy {
            case .created:
                block(root)
            case .ready:
                _ = flow
                    .rxFlowReady
                    .asDriver(onErrorJustReturn: true)
                    .drive(onNext: { _ in
                        block(root)
                    })
            }
    }
}

#endif
