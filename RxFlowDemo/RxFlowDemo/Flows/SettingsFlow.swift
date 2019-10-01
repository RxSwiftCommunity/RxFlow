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
import RxCocoa

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

    deinit {
        print("\(type(of: self)): \(#function)")
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? DemoStep else { return .none }

        switch step {
        case .settingsAreRequired:
            return navigateToSettingsScreen()
        case .loginIsRequired:
            return navigateToLoginScreen()
        case .userIsLoggedIn:
            return popToMasterViewController()
        case .apiKeyIsRequired:
            return navigateToApiKeyScreen()
        case .apiKeyIsFilledIn:
            return popToMasterViewController()
        case .aboutIsRequired:
            return navigateToAboutScreen()
        case .settingsAreComplete:
            return .end(forwardToParentFlowWithStep: DemoStep.settingsAreComplete)
        case let .alert(message):
            return navigateToAlertScreen(message: message)
        default:
            return .none
        }
    }

    private func navigateToAlertScreen(message: String) -> FlowContributors {
        let alert = UIAlertController(title: "Demo", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        rootViewController.present(alert, animated: true)
        return .none
    }

    private func popToMasterViewController() -> FlowContributors {
        if let navigationController = self.rootViewController.viewControllers[0] as? UINavigationController {
            navigationController.popToRootViewController(animated: true)
        }
        return .none
    }

    private func navigateToSettingsScreen() -> FlowContributors {
        let navigationController = UINavigationController()
        let settingsListViewController = SettingsListViewController.instantiate()
        let settingsLoginViewController = SettingsLoginViewController.instantiate()

        self.rootViewController.viewControllers = [navigationController, settingsLoginViewController]
        self.rootViewController.preferredDisplayMode = .allVisible

        settingsLoginViewController.title = "Login"

        navigationController.viewControllers = [settingsListViewController]
        if let navigationBarItem = navigationController.navigationBar.items?[0] {
            let settingsButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                                 target: self.settingsStepper,
                                                 action: #selector(SettingsStepper.settingsDone))
            navigationBarItem.setRightBarButton(settingsButton, animated: false)
        }

        return .multiple(flowContributors: [
            .contribute(withNext: settingsListViewController),
            .contribute(withNext: settingsLoginViewController),
            .forwardToCurrentFlow(withStep: DemoStep.alert("Demo of multiple Flow Contributor"))
        ])
    }

    private func navigateToLoginScreen() -> FlowContributors {
        let settingsLoginViewController = SettingsLoginViewController.instantiate()
        settingsLoginViewController.title = "Login"
        self.rootViewController.showDetailViewController(settingsLoginViewController, sender: nil)
        return .one(flowContributor: .contribute(withNext: settingsLoginViewController))
    }

    private func navigateToApiKeyScreen() -> FlowContributors {
        let settingsViewModel = SettingsApiKeyViewModel()
        let settingsViewController = SettingsApiKeyViewController.instantiate(withViewModel: settingsViewModel,
                                                                              andServices: self.services)
        settingsViewController.title = "API Key"
        self.rootViewController.showDetailViewController(settingsViewController, sender: nil)
        return .one(flowContributor: .contribute(withNextPresentable: settingsViewController, withNextStepper: settingsViewModel))
    }

    private func navigateToAboutScreen() -> FlowContributors {
        let settingsAboutViewController = SettingsAboutViewController.instantiate()
        settingsAboutViewController.title = "About"
        self.rootViewController.showDetailViewController(settingsAboutViewController, sender: nil)
        return .none
    }

}

class SettingsStepper: Stepper {

    let steps = PublishRelay<Step>()

    var initialStep: Step {
        return DemoStep.settingsAreRequired
    }

    @objc func settingsDone() {
        self.steps.accept(DemoStep.settingsAreComplete)
    }
}
