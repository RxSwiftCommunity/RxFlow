//
//  AppFlow.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 18-02-08.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxFlow

class AppFlow: Flow {

    var root: Presentable {
        return self.rootWindow
    }

    private let rootWindow: UIWindow
    private let service: MoviesService

    init(withWindow window: UIWindow, andService service: MoviesService) {
        self.rootWindow = window
        self.service = service
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? DemoStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .apiKey:
            return navigationToApiScreen()
        case .apiKeyIsComplete:
            return navigationToDashboardScreen()
        default:
            return NextFlowItems.stepNotHandled
        }

    }

    private func navigationToApiScreen () -> NextFlowItems {
        let settingsViewController = SettingsViewController.instantiate()
        self.rootWindow.rootViewController = settingsViewController
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: settingsViewController, nextStepper: settingsViewController))
    }

    private func navigationToDashboardScreen () -> NextFlowItems {
        let tabbarController = UITabBarController()
        let wishlistStepper = WishlistStepper()
        let wishListFlow = WishlistFlow(withService: self.service, andStepper: wishlistStepper)
        let watchedFlow = WatchedFlow(withService: self.service)

        Flows.whenReady(flow1: wishListFlow, flow2: watchedFlow, block: { [unowned self] (root1: UINavigationController, root2: UINavigationController) in
            let tabBarItem1 = UITabBarItem(title: "Wishlist", image: UIImage(named: "wishlist"), selectedImage: nil)
            let tabBarItem2 = UITabBarItem(title: "Watched", image: UIImage(named: "watched"), selectedImage: nil)
            root1.tabBarItem = tabBarItem1
            root1.title = "Wishlist"
            root2.tabBarItem = tabBarItem2
            root2.title = "Watched"

            tabbarController.setViewControllers([root1, root2], animated: false)
            self.rootWindow.rootViewController = tabbarController
        })

        return NextFlowItems.multiple(flowItems: [NextFlowItem(nextPresentable: wishListFlow, nextStepper: wishlistStepper),
                                                  NextFlowItem(nextPresentable: watchedFlow, nextStepper: OneStepper(withSingleStep: DemoStep.movieList))])
    }

}
