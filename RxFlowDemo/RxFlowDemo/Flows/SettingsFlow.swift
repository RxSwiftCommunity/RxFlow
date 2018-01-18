//
//  SettingsFlow.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-08-09.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxFlow
import RxSwift

class SettingsFlow: Flow {

    var root: UIViewController {
        return self.rootViewController
    }

    let rootViewController = UISplitViewController()

    let settingsStepper: SettingsStepper
    init(withService service: MoviesService, andStepper stepper: SettingsStepper) {
        self.settingsStepper = stepper
        self.rootViewController.preferredDisplayMode = .allVisible
    }

    func navigate(to step: Step) -> [NextFlowItem] {
        guard let step = step as? DemoStep else { return NextFlowItem.noNavigation }

        switch step {
        case .settings:
            let navigationController = UINavigationController()

            let settingsListViewController = SettingsListViewController.instantiate()

            navigationController.viewControllers = [settingsListViewController]
            if let navigationBarItem = navigationController.navigationBar.items?[0] {
                let settingsButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done,
                                                     target: self.settingsStepper,
                                                     action: #selector(SettingsStepper.settingsDone))
                navigationBarItem.setRightBarButton(settingsButton, animated: false)
            }
            self.rootViewController.viewControllers = [navigationController]

            let settingsViewController = SettingsViewController.instantiate()
            settingsViewController.title = "Api Key"
            self.rootViewController.showDetailViewController(settingsViewController, sender: nil)

            return [NextFlowItem(nextPresentable: navigationController, nextStepper: settingsListViewController),
                    NextFlowItem(nextPresentable: settingsViewController, nextStepper: settingsViewController)]
        case .apiKey:
            let settingsViewController = SettingsViewController.instantiate()
            settingsViewController.title = "Api Key"
            self.rootViewController.showDetailViewController(settingsViewController, sender: nil)
            return NextFlowItem.noNavigation
        case .about:
            let settingsAboutViewController = SettingsAboutViewController.instantiate()
            settingsAboutViewController.title = "About"
            self.rootViewController.showDetailViewController(settingsAboutViewController, sender: nil)
            return NextFlowItem.noNavigation
        case .settingsDone:
            self.rootViewController.dismiss(animated: true)
            return NextFlowItem.noNavigation
        default:
            return NextFlowItem.noNavigation
        }

    }
}

class SettingsStepper: Stepper {

    init() {
        self.step.accept(DemoStep.settings)
    }

    @objc func settingsDone () {
        self.step.accept(DemoStep.settingsDone)
    }
}
