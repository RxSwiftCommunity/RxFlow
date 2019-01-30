//
//  DemoStep.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-07-25.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxFlow

enum DemoStep: Step {
    // Login
    case loginIsRequired
    case userIsLoggedIn

    // Api Key
    case apiKeyIsRequired
    case apiKeyIsFilledIn

    // Onboarding
    case onboardingIsRequired
    case onboardingIsComplete

    // Home
    case dashboardIsRequired

    // Movies
    case moviesAreRequired
    case movieIsPicked (withId: Int)
    case castIsPicked (withId: Int)

    // Settings
    case settingsAreRequired
    case settingsAreComplete

    // About
    case aboutIsRequired
}
