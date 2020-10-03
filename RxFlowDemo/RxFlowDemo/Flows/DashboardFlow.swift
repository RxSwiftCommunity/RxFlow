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

class DashboardFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }

    let rootViewController = UITabBarController()
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
        case .dashboardIsRequired:
            return navigateToDashboard()
        default:
            return .none
        }
    }

    private func navigateToDashboard() -> FlowContributors {
        let wishlistStepper = WishlistStepper()
        let trendingStepper = TrendingStepper()

        let wishListFlow = WishlistFlow(withServices: self.services, andStepper: wishlistStepper)
        let watchedFlow = WatchedFlow(withServices: self.services)
        let trendingFlow = TrendingFlow(withServices: self.services, andStepper: trendingStepper)

        Flows.use(wishListFlow, watchedFlow, trendingFlow, when: .created) { [unowned self] (root1: UINavigationController, root2: UINavigationController, root3: UINavigationController) in
            let tabBarItem1 = UITabBarItem(title: "Wishlist", image: UIImage(named: "wishlist"), selectedImage: nil)
            let tabBarItem2 = UITabBarItem(title: "Watched", image: UIImage(named: "watched"), selectedImage: nil)
            let tabBarItem3 = UITabBarItem(title: "Trending", image: UIImage(named: "trending"), selectedImage: nil)
            root1.tabBarItem = tabBarItem1
            root1.title = "Wishlist"
            root2.tabBarItem = tabBarItem2
            root2.title = "Watched"
            root3.tabBarItem = tabBarItem3
            root3.title = "Trending"

            self.rootViewController.setViewControllers([root1, root2, root3], animated: false)
        }

        return .multiple(flowContributors: [.contribute(withNextPresentable: wishListFlow,
                                                        withNextStepper: CompositeStepper(steppers: [OneStepper(withSingleStep: DemoStep.moviesAreRequired), wishlistStepper])),
                                            .contribute(withNextPresentable: watchedFlow,
                                                        withNextStepper: OneStepper(withSingleStep: DemoStep.moviesAreRequired)),
                                            .contribute(withNextPresentable: trendingFlow,
                                                        withNextStepper: trendingStepper)])
    }
}
