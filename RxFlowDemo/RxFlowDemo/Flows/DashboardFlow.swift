//
//  DashboardFlow.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 18-02-14.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxFlow

class DashboardFlow: Flow {

    var root: Presentable {
        return tabBarController
    }

    let tabBarController = UITabBarController()
    private let services: AppServices

    init(withServices services: AppServices) {
        self.services = services
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? DemoStep else { return NextFlowItems.none }

        switch step {
        case .dashboard:
            return navigateToDashboard()
        default:
            return NextFlowItems.none
        }

    }
    
    func navigateToDashboard() -> NextFlowItems {
        let wishlistStepper = WishlistStepper()
        let wishListFlow = WishlistFlow(withServices: self.services, andStepper: wishlistStepper)
        return Flows.whenReady(setupTabBarController: tabBarController, with: [
            TabWithStepperFlowContainer(flow: wishListFlow, title: "Wishlist", image: #imageLiteral(resourceName: "wishlist"), stepper: wishlistStepper),
            TabWithStepperFlowContainer(flow: WatchedFlow(withServices: self.services), title: "Watched", image: #imageLiteral(resourceName: "watched"), withSingleStep: DemoStep.movieList)
        ])
    }
}
