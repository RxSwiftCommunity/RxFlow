//
//  CastListFlow.swift
//  RxFlowDemo
//
//  Created by Li Hao Lai on 30/9/20.
//  Copyright © 2020 RxSwiftCommunity. All rights reserved.
//

import RxFlow
import UIKit

class CastListFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController: CastListViewController
    private let services: AppServices

    init(withServices services: AppServices) {
        self.services = services
        rootViewController = CastListViewController.instantiate(withViewModel: CastListViewModel(), andServices: services)
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? DemoStep else { return .none }

        switch step {
        case .castListAreRequired:
            return navigateToCastListScreen()
        case .castIsPicked(let castId):
            return navigateToCastDetailScreen(with: castId)
        default:
            return .none
        }
    }

    private func navigateToCastListScreen() -> FlowContributors {
        return .one(flowContributor: .contribute(withNextPresentable: rootViewController, withNextStepper: rootViewController.viewModel))
    }

    private func navigateToCastDetailScreen (with castId: Int) -> FlowContributors {
        let viewController = CastDetailViewController.instantiate(withViewModel: CastDetailViewModel(withCastId: castId),
                                                                  andServices: self.services)
        viewController.title = viewController.viewModel.name
        self.rootViewController.navigationController?.pushViewController(viewController, animated: true)
        return .none
    }
}
