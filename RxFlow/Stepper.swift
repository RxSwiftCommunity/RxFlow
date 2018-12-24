//
//  Weftable.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-25.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxSwift
import RxCocoa

/// a Stepper has only one purpose is: emits Steps that correspond to specific navigation states.
/// The Step changes lead to navigation actions in the context of a specific Flow
public protocol Stepper: Synchronizable {

    /// the relay used to emit steps inside this Stepper
    var steps: PublishRelay<Step> { get }

    /// the initial step that will be emitted when listening for this Stepper
    var initialStep: Step { get }
}

// MARK: - default implementation
public extension Stepper {
    var initialStep: Step {
        return NoneStep()
    }
}

/// A Simple Stepper that has one goal: emit a single Step once initialized
public class OneStepper: Stepper {

    public let steps = PublishRelay<Step>()
    private let singleStep: Step

    /// Initialize the OneStepper
    ///
    /// - Parameter singleStep: the step to be emitted once initialized
    public init(withSingleStep singleStep: Step) {
        self.singleStep = singleStep
    }

    public var initialStep: Step {
        return self.singleStep
    }
}

/// A Simple Stepper that has one goal: emit a first default step equal to RxFlowStep.start
public class DefaultStepper: OneStepper {

    /// Initialize the DefaultStepper
    public init () {
        super.init(withSingleStep: RxFlowStep.home)
    }
}

/// A Stepper that combines multiple steppers. All those Steppers will be associated
/// to the Presentable that is given within the NextFlowItem
public class CompositeStepper: Stepper {

    private let disposeBag = DisposeBag()

    public let steps = PublishRelay<Step>()

    /// Initialize
    ///
    /// - Parameter steppers: all these Steppers will be observered by the Coordinator
    public init(steppers: [Stepper]) {
        Observable<Step>.merge(steppers.map { $0.steps.asObservable() }).bind(to: self.steps).disposed(by: self.disposeBag)
    }
}

/// a Stepper that triggers NoStep.
final class NoneStepper: OneStepper {
    convenience init() {
        self.init(withSingleStep: NoneStep())
    }
}
