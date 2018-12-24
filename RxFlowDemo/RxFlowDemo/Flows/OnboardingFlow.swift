//
//  OnboardingFlow.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 18-02-11.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import Foundation
import UIKit.UINavigationController
import RxFlow

class OnboardingFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.navigationBar.topItem?.title = "OnBoarding"
        return viewController
    }()

    private let services: AppServices

    init(withServices services: AppServices) {
        self.services = services
    }

    deinit {
        print("\(type(of: self)): \(#function)")
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? DemoStep else { return .none }

        switch step {
        case .login:
            return navigationToLoginScreen()
        case .loginIsComplete:
            return navigationToApiScreen()
        case .apiKeyIsComplete:
            return .end(forwardToParentFlowWithStep: DemoStep.onboardingIsDone)
        default:
            return .none
        }
    }

    private func navigationToLoginScreen() -> FlowContributors {
        let settingsLoginViewController = SettingsLoginViewController.instantiate()
        settingsLoginViewController.title = "Login"
        self.rootViewController.pushViewController(settingsLoginViewController, animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: settingsLoginViewController,
                                                 withNextStepper: settingsLoginViewController))
    }

    private func navigationToApiScreen() -> FlowContributors {
        let settingsViewModel = SettingsApiKeyViewModel()
        let settingsViewController = SettingsApiKeyViewController.instantiate(withViewModel: settingsViewModel,
                                                                              andServices: self.services)
        settingsViewController.title = "API Key"
        self.rootViewController.pushViewController(settingsViewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: settingsViewController,
                                                 withNextStepper: settingsViewModel))
    }

}
