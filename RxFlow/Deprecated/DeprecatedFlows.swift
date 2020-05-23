//
//  DeprecatedFlows.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 2020-05-16.
//  Copyright © 2020 RxSwiftCommunity. All rights reserved.
//

#if canImport(UIKit)

import RxRelay
import RxSwift
import UIKit

@available(*, deprecated, message: "You should use Flows.use()")
public extension Flows {
    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flows: Flow(s) to be observed
    ///   - block: block to execute whenever the Flows are ready to use
    @available(*, deprecated, message: "You should use Flows.use()")
    static func whenReady<RootType: UIViewController>(flows: [Flow],
                                                      block: @escaping ([RootType]) -> Void) {
        let flowsReadinesses = flows.map { $0.rxFlowReady }
        let roots = flows.compactMap { $0.root as? RootType }
        guard roots.count == flows.count else {
            fatalError("Type mismatch, Flows roots types do not match the types awaited in the block")
        }

        _ = Single.zip(flowsReadinesses) { _ in Void() }
            .asDriver(onErrorJustReturn: Void())
            .drive(onNext: { _ in
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
    @available(*, deprecated, message: "You should use Flows.use()")
    static func whenReady<RootType1, RootType2, RootType3, RootType4, RootType5>(flow1: Flow,
                                                                                 flow2: Flow,
                                                                                 flow3: Flow,
                                                                                 flow4: Flow,
                                                                                 flow5: Flow,
                                                                                 block: @escaping (_ flow1Root: RootType1,
        _ flow2Root: RootType2,
        _ flow3Root: RootType3,
        _ flow4Root: RootType4,
        _ flow5Root: RootType5) -> Void)
        where
        RootType1: UIViewController,
        RootType2: UIViewController,
        RootType3: UIViewController,
        RootType4: UIViewController,
        RootType5: UIViewController {
            guard
                let root1 = flow1.root as? RootType1,
                let root2 = flow2.root as? RootType2,
                let root3 = flow3.root as? RootType3,
                let root4 = flow4.root as? RootType4,
                let root5 = flow5.root as? RootType5 else {
                    fatalError("Type mismatch, Flows roots types do not match the types awaited in the block")
            }

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
    @available(*, deprecated, message: "You should use Flows.use()")
    static func whenReady<RootType1, RootType2, RootType3, RootType4>(flow1: Flow,
                                                                      flow2: Flow,
                                                                      flow3: Flow,
                                                                      flow4: Flow,
                                                                      block: @escaping (_ flow1Root: RootType1,
        _ flow2Root: RootType2,
        _ flow3Root: RootType3,
        _ flow4Root: RootType4) -> Void)
        where
        RootType1: UIViewController,
        RootType2: UIViewController,
        RootType3: UIViewController,
        RootType4: UIViewController {
            guard
                let root1 = flow1.root as? RootType1,
                let root2 = flow2.root as? RootType2,
                let root3 = flow3.root as? RootType3,
                let root4 = flow4.root as? RootType4 else {
                    fatalError("Type mismatch, Flows roots types do not match the types awaited in the block")
            }

            _ = Single.zip(flow1.rxFlowReady,
                           flow2.rxFlowReady,
                           flow3.rxFlowReady,
                           flow4.rxFlowReady) { _, _, _, _ in Void()
            }
            .asDriver(onErrorJustReturn: Void())
            .drive(onNext: { _ in
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
    @available(*, deprecated, message: "You should use Flows.use()")
    static func whenReady<RootType1, RootType2, RootType3>(flow1: Flow,
                                                           flow2: Flow,
                                                           flow3: Flow,
                                                           block: @escaping (_ flow1Root: RootType1,
        _ flow2Root: RootType2,
        _ flow3Root: RootType3) -> Void)
        where
        RootType1: UIViewController,
        RootType2: UIViewController,
        RootType3: UIViewController {
            guard
                let root1 = flow1.root as? RootType1,
                let root2 = flow2.root as? RootType2,
                let root3 = flow3.root as? RootType3 else {
                    fatalError("Type mismatch, Flows roots types do not match the types awaited in the block")
            }

            _ = Single.zip(flow1.rxFlowReady,
                           flow2.rxFlowReady,
                           flow3.rxFlowReady) { _, _, _ in Void() }
                .asDriver(onErrorJustReturn: Void())
                .drive(onNext: { _ in
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
    @available(*, deprecated, message: "You should use Flows.use()")
    static func whenReady<RootType1: UIViewController, RootType2: UIViewController>(flow1: Flow,
                                                                                    flow2: Flow,
                                                                                    block: @escaping (_ flow1Root: RootType1,
        _ flow2Root: RootType2) -> Void) {
        guard   let root1 = flow1.root as? RootType1,
            let root2 = flow2.root as? RootType2 else {
                fatalError("Type mismatch, Flows root types do not match the types awaited in the block")
        }

        _ = Single.zip(flow1.rxFlowReady,
                       flow2.rxFlowReady) { _, _ in Void() }
            .asDriver(onErrorJustReturn: Void())
            .drive(onNext: { _ in
                block(root1, root2)
            })
    }

    /// Allow to be triggered only when Flow given as parameters is ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - flow1: Flow to be observed
    ///   - block: block to execute whenever the Flow is ready to use
    @available(*, deprecated, message: "You should use Flows.use()")
    static func whenReady<RootType: UIViewController>(flow1: Flow,
                                                      block: @escaping (_ flowRoot1: RootType) -> Void) {
        guard let root = flow1.root as? RootType else {
            fatalError("Type mismatch, Flow root type does not match the type awaited in the block")
        }

        _ = flow1
            .rxFlowReady
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { _ in
                block(root)
            })
    }
}

#endif
