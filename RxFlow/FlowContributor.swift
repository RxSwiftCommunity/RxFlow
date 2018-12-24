//
//  FlowContributor.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-10-09.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

@available(*, deprecated, message: "You should use NextFlowItem")
/// typealias to allow compliance with older versions of RxFlow. NextFlowItem should be replaced by FlowContributor
public typealias NextFlowItem = FlowContributor

/// A FlowContributor is the result of the coordination action between a Flow and a Step (See Flow.navigate(to:) function)
/// It describes the next thing that will be presented (a Presentable) and
/// the next thing the FlowCoordinator will listen to, to have the next navigation Steps (a Stepper).
/// If a navigation action does not have to lead to a FlowContributor, it is possible to have an empty FlowContributor array
public class FlowContributor {

    /// The presentable that will be handle by the FlowCoordinator. The FlowCoordinator is not
    /// meant to display this presentable, it will only handle its "Display" status
    /// so that the associated Stepper will be listened to or not
    public let nextPresentable: Presentable

    /// The Stepper that will be handle by the FlowCoordinator. It will emit the new
    /// navigation Steps. The FlowCoordinator will listen to them only if the associated
    /// Presentable is displayed
    public let nextStepper: Stepper

    /// Initialize a new FlowContributor
    ///
    /// - Parameters:
    ///   - nextPresentable: the next presentable to be handled by the FlowCoordinator
    ///   - nextStepper: the next Steper to be handled by the FlowCoordinator
    public init(nextPresentable presentable: Presentable, nextStepper stepper: Stepper) {
        self.nextPresentable = presentable
        self.nextStepper = stepper
    }
}

@available(*, deprecated, message: "You should use FlowContributors")
/// typealias to allow compliance with older versions of RxFlow. NextFlowItems should be replaced by FlowContributors
public typealias NextFlowItems = FlowContributors

/// FlowContributors reprent the next things that will trigger
/// navigation actions inside a Flow
///
/// - multiple: a Flow will trigger several FlowContributors at the same time for the same Step
/// - one: a Flow will trigger only one FlowContributor for a Step
/// - end: a Flow will trigger a special FlowContributor that represents the dismissal of this Flow
/// - none: no further navigation will be triggered for a Step
/// - contributeToParentFlow: the parent Flow (if exists) will be triggered with the given Step
/// - contributeToCurrentFlow: the current Flow will be triggered with the given Step (it is a step forwarding)
/// - triggerParentFlow: same as noneWith. It is now deprecated
public enum FlowContributors {
    /// a Flow will trigger several FlowContributor at the same time for the same Step
    case multiple (flowContributors: [FlowContributor])
    /// a Flow will trigger only one FlowContributor for a Step
    case one (flowContributor: FlowContributor)
    /// a Flow will trigger a special FlowContributor that represents the dismissal of this Flow
    case end (contributingToParentFlowWithStep: Step)
    /// no further navigation will be triggered for a Step
    case none
    /// a Flow will trigger a special FlowContributor that allows to trigger a new Step for the parent Flow
    /// (same as .end but without stopping listening for child flow steppers)
    case contributeToParentFlow (withStep: Step)
    /// the given step will be forwarded to the current flow
    case contributeToCurrentFlow (withStep: Step)
    /// same as parentFlow (withStep: Step). Should not be used anymore
    @available(*, deprecated, message: "You should use contributeToParentFlow (withStep: Step)")
    case triggerParentFlow (withStep: Step)
}
