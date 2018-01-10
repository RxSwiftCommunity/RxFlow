//
//  Step.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-23.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

/// A Step describes a possible state of navigation insie a Flow
public protocol Step {
}

/// An empty Step used internally
struct NoStep: Step {
}
