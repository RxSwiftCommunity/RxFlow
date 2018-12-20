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

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? DemoStep else { return NextFlowItems.none }

        switch step {
        case .dashboard:
            return navigateToDashboard()
        case .logout:
            return NextFlowItems.end(withStepForParentFlow: step)
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
        }

        return .multiple(flowItems: [NextFlowItem(nextPresentable: wishListFlow,
                                                  nextStepper: wishlistStepper),
                                     NextFlowItem(nextPresentable: watchedFlow,
                                                  nextStepper: OneStepper(withSingleStep: DemoStep.movieList))])
    }
}
