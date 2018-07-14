//
//  Step.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-23.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

final class StepContext {

    public var fromChildFlow: Flow?
    weak var withinFlow: Flow?

    let step: Step

    init(with step: Step) {
        self.step = step
    }

    static var none: StepContext {
        return StepContext(with: NoneStep())
    }
}

/// A Step describes a possible state of navigation inside a Flow
public protocol Step {
}

struct NoneStep: Step {
}
