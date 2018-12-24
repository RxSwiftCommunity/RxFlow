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
import RxCocoa

class SettingsApiKeyViewModel: Stepper, ServicesViewModel {

    let steps = PublishRelay<Step>()
    typealias Services = HasPreferencesService

    var services: Services!

    func setApiKey() {
        self.services.preferencesService.setOnboarded()
    }
}
