//
//  DashboardFlow.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 18-02-14.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import Foundation
import UIKit
import RxFlow
import RxSwift

class DashboardFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }

    let rootViewController = UITabBarController()
    private let services: AppServices
    private let stepper: DashboardStepper

    init(withServices services: AppServices, andStepper stepper: DashboardStepper) {
        self.services = services
        self.stepper = stepper
    }

    deinit {
        print("\(type(of: self)): \(#function)")
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? DemoStep else { return NextFlowItems.none }

        switch step {
        case .dashboard:
            return navigateToDashboard()
        case .settings:
            return navigateToLogin()
        case .loginIsComplete:
            self.rootViewController.presentedViewController?.dismiss(animated: true)
            return .none
        default:
            return .none
        }
    }

    private func navigateToDashboard() -> NextFlowItems {
        let wishlistStepper = WishlistStepper()
        let wishListFlow = WishlistFlow(withServices: self.services, andStepper: wishlistStepper)
        let watchedFlow = WatchedFlow(withServices: self.services)

        Flows.whenReady(flow1: wishListFlow, flow2: watchedFlow) { [unowned self] (root1: UINavigationController, root2: UINavigationController) in
            let tabBarItem1 = UITabBarItem(title: "Wishlist", image: UIImage(named: "wishlist"), selectedImage: nil)
            let tabBarItem2 = UITabBarItem(title: "Watched", image: UIImage(named: "watched"), selectedImage: nil)
            root1.tabBarItem = tabBarItem1
            root1.title = "Wishlist"
            root2.tabBarItem = tabBarItem2
            root2.title = "Watched"

            self.rootViewController.setViewControllers([root1, root2], animated: false)
            self.stepper.checkLogin()
        }

        return .multiple(flowItems: [NextFlowItem(nextPresentable: wishListFlow,
                                                  nextStepper: wishlistStepper),
                                     NextFlowItem(nextPresentable: watchedFlow,
                                                  nextStepper: OneStepper(withSingleStep: DemoStep.movieList))])
    }

    private func navigateToLogin() -> NextFlowItems {
        let viewController = SettingsLoginViewController.instantiate()
        self.rootViewController.present(viewController, animated: true)
        return .one(flowItem: NextFlowItem(nextPresentable: viewController,
                                           nextStepper: viewController))
    }
}

class DashboardStepper: Stepper, HasDisposeBag {
    init() {
        self.step.accept(DemoStep.dashboard)
    }

    func checkLogin () {
        // timer is just here to allow to view how things happen
        Observable<Int>.timer(2, scheduler: MainScheduler.instance).map { _ -> Step in return DemoStep.settings }.bind(to: self.step).disposed(by: self.disposeBag)
    }
}
