//
//  MainFlow.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-08-09.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxFlow
import RxSwift

class MainFlow: Flow {

    var root: UIViewController {
        return self.rootViewController
    }

    private let rootViewController: UINavigationController
    private let service: MoviesService

    init(with service: MoviesService) {
        self.rootViewController = UINavigationController()
        self.rootViewController.setNavigationBarHidden(true, animated: false)
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
        rootViewController.pushViewController(settingsViewController, animated: false)
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
            self.rootViewController.pushViewController(tabbarController, animated: true)
        })

        return NextFlowItems.multiple(flowItems: [NextFlowItem(nextPresentable: wishListFlow, nextStepper: wishlistStepper),
                                                  NextFlowItem(nextPresentable: watchedFlow, nextStepper: OneStepper(withSingleStep: DemoStep.movieList))])
    }
}
