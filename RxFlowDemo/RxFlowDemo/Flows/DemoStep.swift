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
    case onboardingIsDone
    case apiKey
    case apiKeyIsComplete
    case login
    case loginIsComplete

    // Dashboard
    case dashboard

    // Movies
    case movieList
    case moviePicked (withMovieId: Int)
    case castPicked (withCastId: Int)

    // Settings
    case settings
    case about
    case aboutIsComplete
    case settingsIsComplete
}
