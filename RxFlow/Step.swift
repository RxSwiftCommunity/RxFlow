//
//  Step.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-23.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

final class StepContext: CustomStringConvertible {
    public var fromChildFlow: Flow?
    weak var withinFlow: Flow?

    let step: Step

    init(with step: Step, withinFlow: Flow? = nil) {
        self.step = step
        self.withinFlow = withinFlow
    }

    static var none: StepContext {
        return StepContext(with: NoneStep())
    }

    var description: String {
        return "step: \(self.step), withinFlow: \(String(describing: self.withinFlow))"
    }

}

/// A Step describes a possible state of navigation inside a Flow
public protocol Step {
}

struct NoneStep: Step {
}
