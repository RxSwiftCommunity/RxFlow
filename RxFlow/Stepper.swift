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
public protocol Stepper: Synchronizable {
}

/// A Simple Stepper that has one goal: emit a single Step once initialized
public class OneStepper: Stepper {

    /// Initialise the OneStepper
    ///
    /// - Parameter singleStep: the step to be emitted once initialized
    public init(withSingleStep singleStep: Step) {
        self.step.accept(singleStep)
    }
}

/// a Stepper that triggers NoStep.
class NoneStepper: OneStepper {
    convenience init() {
        self.init(withSingleStep: NoStep())
    }
}

public extension Stepper {

    /// The step Subject in which to publish new Steps
    public var step: BehaviorRelay<Step> {
        return self.synchronized {
            if let subject = objc_getAssociatedObject(self, &subjectContext) as? BehaviorRelay<Step> {
                return subject
            }
            let newSubject = BehaviorRelay<Step>(value: NoStep())
            objc_setAssociatedObject(self, &subjectContext, newSubject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newSubject
        }
    }

    /// the Rx Obsersable that will trigger new Steps
    internal var steps: Observable<Step> {
        return self.step.asObservable()
    }
}
