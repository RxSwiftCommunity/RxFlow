//
//  DemoStep.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-07-25.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxFlow

enum DemoStep: Step {
    case onboarding
    case apiKey
    case apiKeyIsComplete
    case login
    case loginIsComplete
    case onboardingIsComplete

    case dashboard
    case movieList

    case moviePicked (withMovieId: Int)
    case castPicked (withCastId: Int)

    case settings
    case about
    case settingsIsComplete
}
