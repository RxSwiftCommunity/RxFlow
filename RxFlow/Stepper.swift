//
//  Weftable.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-25.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxSwift
import RxCocoa

private var subjectContext: UInt8 = 0

/// a Stepper has only one purpose is: emits Steps that correspond to specific navigation states.
/// The Step changes lead to navigation actions in the context of a specific Flow
public protocol Stepper: class, Synchronizable {

    /// The Observable corresponding to the Steps triggered by the Stepper
    var steps: Observable<Step> { get }

}

/// A Simple Stepper that has one goal: emit a single Step once initialized
public class OneStepper: Stepper {

    /// Initialize the OneStepper
    ///
    /// - Parameter singleStep: the step to be emitted once initialized
    public init(withSingleStep singleStep: Step) {
        self.step.accept(singleStep)
    }
}

/// A Stepper that combines multiple steppers. All those Steppers will be associated
/// to the Presentable that is given within the NextFlowItem
final public class CompositeStepper: Stepper {

    /// the Rx Obsersable that will emits new Steps
    public private(set) var steps: Observable<Step>

    /// Initialize
    ///
    /// - Parameter steppers: all these Steppers will be observered by the Coordinator
    public init(steppers: [Stepper]) {
        let allSteps = steppers.map { $0.steps }
        self.steps = Observable.merge(allSteps)
    }
}

/// a Stepper that triggers NoStep.
final class NoneStepper: OneStepper {
    convenience init() {
        self.init(withSingleStep: NoneStep())
    }
}

public extension Stepper {

    /// The step Subject in which to publish new Steps
    public var step: BehaviorRelay<Step> {
        return self.synchronized {
            if let subject = objc_getAssociatedObject(self, &subjectContext) as? BehaviorRelay<Step> {
                return subject
            }
            let newSubject = BehaviorRelay<Step>(value: NoneStep())
            objc_setAssociatedObject(self, &subjectContext, newSubject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newSubject
        }
    }

    /// the Rx Obsersable that will trigger new Steps
    public var steps: Observable<Step> {
        return self.step.asObservable()
    }
}
