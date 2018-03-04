//
//  PreferencesService.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 18-02-10.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import Foundation

protocol HasPreferencesService {
    var preferencesService: PreferencesService { get }
}

/// Represents the keys that are used to store user defaults
struct UserPreferences {
    private init () {}

    /// key for onBoarded preference
    static let onBoarded = "onBoarded"
}

/// This service manage the user preferences
class PreferencesService {

    /// sets the onBoarded preference to true
    func setOnboarding () {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: UserPreferences.onBoarded)
    }

    /// Returns true if the user has already onboarded, false otherwise
    ///
    /// - Returns: true if the user has already onboarded, false otherwise
    func isOnboarded () -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: UserPreferences.onBoarded)
    }
}
