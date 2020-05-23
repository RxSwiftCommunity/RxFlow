//
//  DeprecatedFlowCoordinator.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 2020-05-16.
//  Copyright © 2020 RxSwiftCommunity. All rights reserved.
//

#if canImport(UIKit)

/// typealias to allow compliance with older versions of RxFlow. Coordinator should be replaced by FlowCoordinator
@available(*, deprecated, message: "You should use FlowCoordinator")
public typealias Coordinator = FlowCoordinator

#endif
