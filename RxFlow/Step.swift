//
//  Step.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-07-23.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

/// A Step describes a possible state of navigation inside a Flow
public protocol Step {}

struct NoneStep: Step, Equatable {}

/// Standard RxFlow Steps
///
/// - home: can be used to express a Flow first step
public enum RxFlowStep: Step {
    /// can be used to express a Flow first step
    case home
}
