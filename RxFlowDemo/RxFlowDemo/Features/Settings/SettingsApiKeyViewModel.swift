//
//  SettingsViewModel.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 18-02-17.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxFlow
import RxSwift

class SettingsApiKeyViewModel: Stepper, ServicesViewModel {

    typealias Services = HasPreferencesService

    var services: Services!

    func setApiKey () {
        if !self.services.preferencesService.isOnboarded() {
            self.services.preferencesService.setOnboarding()
        }
        self.step.accept(DemoStep.apiKeyIsComplete)
    }
}
