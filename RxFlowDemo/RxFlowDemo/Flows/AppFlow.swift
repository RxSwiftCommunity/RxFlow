//
//  AppFlow.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 18-02-08.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import Foundation
import UIKit
import RxFlow

class AppFlow: Flow {
    var root: Presentable {
        return self.rootWindow
    }

    private let rootWindow: UIWindow
    private let services: AppServices

    init(withWindow window: UIWindow, andServices services: AppServices) {
        self.rootWindow = window
        self.services = services
    }

    deinit {
        print("\(type(of: self)): \(#function)")
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? DemoStep else { return NextFlowItems.none }

        switch step {
        case .onboardingIsRequired:
            return navigationToOnboardingScreen()
        case .onboardingIsComplete, .dashboardIsRequired:
            return navigationToDashboardScreen()
        default:
            return NextFlowItems.none
        }
    }

    private func navigationToOnboardingScreen() -> NextFlowItems {
        let onboardingFlow = OnboardingFlow(withServices: self.services)
        Flows.whenReady(flow1: onboardingFlow) { [unowned self] (root) in
            self.rootWindow.rootViewController = root
        }

        return .one(flowItem: NextFlowItem(nextPresentable: onboardingFlow,
                                           nextStepper: OneStepper(withSingleStep: DemoStep.loginIsRequired)))
    }

    private func navigationToDashboardScreen() -> NextFlowItems {
        let dashboardFlow = DashboardFlow(withServices: self.services)

        Flows.whenReady(flow1: dashboardFlow) { [unowned self] (root) in
            self.rootWindow.rootViewController = root
        }

        return .one(flowItem: NextFlowItem(nextPresentable: dashboardFlow,
                                           nextStepper: OneStepper(withSingleStep: DemoStep.dashboardIsRequired)))
    }

}

class AppStepper: Stepper {
    init(withServices services: AppServices) {
        if services.preferencesService.isOnboarded() {
            self.step.accept(DemoStep.dashboardIsRequired)
        } else {
            self.step.accept(DemoStep.onboardingIsRequired)
        }
    }
}
