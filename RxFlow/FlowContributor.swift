//
//  FlowContributor.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-10-09.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

#if canImport(UIKit)

/// A FlowContributor describes the next thing that will contribute to a Flow.
///
/// - contribute: the given stepper will emit steps
/// (according to lifecycle of the given presentable and the allowStepWhenNotPresented parameter) that will contribute
/// to the current Flow
/// - forwardToCurrentFlow: the given step will be forwarded to the current flow
/// - forwardToParentFlow: the given step will be forwarded to the parent flow
public enum FlowContributor {
    /// the given stepper will emit steps, according to lifecycle of the given presentable, that will contribute to the current Flow
    /// `allowStepWhenNotPresented` can be passed to make the coordinator accept the steps from the stepper even id
    /// the presentable is not visible
    /// `allowStepWhenDismissed` can be passed to make the coordinator accept the steps from the stepper even
    /// the presentable  has dismissed (e.g UIPageViewController's child)
    case contribute(withNextPresentable: Presentable,
                    withNextStepper: Stepper,
                    allowStepWhenNotPresented: Bool = false,
                    allowStepWhenDismissed: Bool = false)
    /// the "withStep" step will be forwarded to the current flow
    case forwardToCurrentFlow(withStep: Step)
    /// the "withStep" step will be forwarded to the parent flow
    case forwardToParentFlow(withStep: Step)

    /// Shortcut static func that returns a .contribute(withNextPresentable: _, withNextStepper: _)
    /// in case we have a single actor that is a Presentable and also a Stepper
    ///
    /// - Parameter nextPresentableAndStepper
    /// - Returns: .contribute(withNextPresentable: withNext, withNextStepper: withNext)
    public static func contribute(withNext nextPresentableAndStepper: Presentable & Stepper) -> FlowContributor {
        return .contribute(withNextPresentable: nextPresentableAndStepper, withNextStepper: nextPresentableAndStepper)
    }
}

/// typealias to allow compliance with older versions of RxFlow. NextFlowItems should be replaced by FlowContributors
@available(*, deprecated, message: "You should use FlowContributors")
public typealias NextFlowItems = FlowContributors

/// FlowContributors represent the next things that will trigger
/// navigation actions inside a Flow
///
/// - multiple: several FlowContributors will contribute to the Flow
/// - one: only one FlowContributor will contribute to the Flow (see the FlowContributor enum)
/// - end: represents the dismissal of this Flow, forwarding the given step to the parent Flow
/// - none: no further navigation will be triggered
/// - triggerParentFlow: same as .one(flowContributor: .forwardToParentFlow(withStep: Step)). It is deprecated.
public enum FlowContributors {
    /// a Flow will trigger several FlowContributor at the same time for the same Step
    case multiple (flowContributors: [FlowContributor])
    /// a Flow will trigger only one FlowContributor for a Step
    case one (flowContributor: FlowContributor)
    /// a Flow will trigger a special FlowContributor that represents the dismissal of this Flow
    case end (forwardToParentFlowWithStep: Step)
    /// no further navigation will be triggered for a Step
    case none
    /// same as .one(flowContributor: .forwardToParentFlow(withStep: Step)). Should not be used anymore
    @available(*, deprecated, message: "You should use .one(flowContributor: .forwardToParentFlow(withStep: Step))")
    case triggerParentFlow (withStep: Step)
}

#endif
