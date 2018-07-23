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

    func setApiKey() -> Single<DemoStep> {
        return Single.create { [services] single in
            guard let services = services else { fatalError("Missing services") }

            if !services.preferencesService.isOnboarded() {
                services.preferencesService.setOnboarding()
            }

            single(.success(.apiKeyIsComplete))

            return Disposables.create { }
        }
    }
}
