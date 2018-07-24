//
//  SettingsFlow.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-08-09.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import UIKit
import RxFlow
import RxSwift

class SettingsFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController = UISplitViewController()
    private let settingsStepper: SettingsStepper
    private let services: AppServices

    init(withServices services: AppServices, andStepper stepper: SettingsStepper) {
        self.settingsStepper = stepper
        self.services = services
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? DemoStep else { return NextFlowItems.none }

        switch step {
        case .settings:
            return navigateToSettingsScreen()
        case .login:
            return navigateToLoginScreen()
        case .loginIsComplete:
            return popToMasterViewController()
        case .apiKey:
            return navigateToApiKeyScreen()
        case .apiKeyIsComplete:
            return popToMasterViewController()
        case .about:
            return navigateToAboutScreen()
        case .settingsIsComplete:
            return NextFlowItems.end(withStepForParentFlow: DemoStep.settingsIsComplete)
        default:
            return NextFlowItems.none
        }
    }

    private func popToMasterViewController() -> NextFlowItems {
        if let navigationController = self.rootViewController.viewControllers[0] as? UINavigationController {
            navigationController.popToRootViewController(animated: true)
        }
        return .none
    }

    private func navigateToSettingsScreen() -> NextFlowItems {
        let navigationController = UINavigationController()
        let settingsListViewController = SettingsListViewController.instantiate()
        let settingsLoginViewController = SettingsLoginViewController.instantiate()

        self.rootViewController.viewControllers = [navigationController, settingsLoginViewController]
        self.rootViewController.preferredDisplayMode = .allVisible

        settingsLoginViewController.title = "Login"

        navigationController.viewControllers = [settingsListViewController]
        if let navigationBarItem = navigationController.navigationBar.items?[0] {
            let settingsButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done,
                                                 target: self.settingsStepper,
                                                 action: #selector(SettingsStepper.settingsDone))
            navigationBarItem.setRightBarButton(settingsButton, animated: false)
        }

        return .multiple(flowItems: [NextFlowItem(nextPresentable: settingsListViewController,
                                                  nextStepper: settingsListViewController),
                                    NextFlowItem(nextPresentable: settingsLoginViewController,
                                                 nextStepper: settingsLoginViewController)])
    }

    private func navigateToLoginScreen() -> NextFlowItems {
        let settingsLoginViewController = SettingsLoginViewController.instantiate()
        settingsLoginViewController.title = "Login"
        self.rootViewController.showDetailViewController(settingsLoginViewController, sender: nil)
        return .one(flowItem: NextFlowItem(nextPresentable: settingsLoginViewController,
                                           nextStepper: settingsLoginViewController))
    }

    private func navigateToApiKeyScreen() -> NextFlowItems {
        let settingsViewModel = SettingsApiKeyViewModel()
        let settingsViewController = SettingsApiKeyViewController.instantiate(withViewModel: settingsViewModel,
                                                                              andServices: self.services)
        settingsViewController.title = "API Key"
        self.rootViewController.showDetailViewController(settingsViewController, sender: nil)
        return .one(flowItem: NextFlowItem(nextPresentable: settingsViewController,
                                           nextStepper: settingsViewModel))
    }

    private func navigateToAboutScreen() -> NextFlowItems {
        let settingsAboutViewController = SettingsAboutViewController.instantiate()
        settingsAboutViewController.title = "About"
        self.rootViewController.showDetailViewController(settingsAboutViewController, sender: nil)
        return .one(flowItem: NextFlowItem(nextPresentable: settingsAboutViewController,
                                           nextStepper: settingsAboutViewController))
    }

}

class SettingsStepper: Stepper {
    init() {
        self.step.accept(DemoStep.settings)
    }

    @objc func settingsDone() {
        self.step.accept(DemoStep.settingsIsComplete)
    }
}
