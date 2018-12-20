//
//  DemoStep.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-07-25.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxFlow

enum DemoStep: Step {
    // global
    case logout

    // Onboarding
    case onboarding
    case apiKey
    case apiKeyIsComplete
    case login
    case loginIsComplete
    case onboardingIsComplete

    // Dashboard
    case dashboard
    case movieList

    // Movies
    case moviePicked (withMovieId: Int)
    case castPicked (withCastId: Int)

    // Settings
    case settings
    case about
    case settingsIsComplete
}
