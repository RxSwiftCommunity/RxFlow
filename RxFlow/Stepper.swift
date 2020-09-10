//
//  Stepper.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-25.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxCocoa
import RxSwift

/// a Stepper has only one purpose is: emits Steps that correspond to specific navigation states.
/// The Step changes lead to navigation actions in the context of a specific Flow
public protocol Stepper {
    /// the relay used to emit steps inside this Stepper
    var steps: PublishRelay<Step> { get }

    /// the initial step that will be emitted when listening to this Stepper
    var initialStep: Step { get }

    /// function called when stepper is listened by the FlowCoordinator
    func readyToEmitSteps ()
}

// MARK: - default implementation
public extension Stepper {
    var initialStep: Step {
        return NoneStep()
    }

    func readyToEmitSteps () {}
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

/// A Simple Stepper that has one goal: emit a first default step equal to RxFlowStep.home
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
    private let innerSteppers: [Stepper]
    public let steps = PublishRelay<Step>()

    /// Initialize
    ///
    /// - Parameter steppers: all these Steppers will be observed by the Coordinator
    public init(steppers: [Stepper]) {
        self.innerSteppers = steppers
    }

    public func readyToEmitSteps() {
        let initialSteps = Observable<Step>.from(self.innerSteppers.map { $0.initialStep })

        let nextSteps = Observable<Step>
            .merge(self.innerSteppers.map { $0.steps.asObservable() })

        initialSteps
            .concat(nextSteps)
            .bind(to: self.steps)
            .disposed(by: self.disposeBag)

        self.innerSteppers.forEach { stepper in
            stepper.readyToEmitSteps()
        }
    }
}

/// a Stepper that triggers NoStep.
final class NoneStepper: OneStepper {
    convenience init() {
        self.init(withSingleStep: NoneStep())
    }
}
