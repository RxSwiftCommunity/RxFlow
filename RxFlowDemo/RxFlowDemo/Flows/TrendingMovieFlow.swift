//
//  TrendingMovieFlow.swift
//  RxFlowDemo
//
//  Created by Li Hao Lai on 29/9/20.
//  Copyright © 2020 RxSwiftCommunity. All rights reserved.
//

import RxFlow
import UIKit

class TrendingMovieFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController: WatchedViewController
    private let services: AppServices

    init(withServices services: AppServices) {
        self.services = services
        rootViewController = WatchedViewController.instantiate(withViewModel: WatchedViewModel(),
                                                               andServices: self.services)
    }

    func navigate(to step: Step) -> FlowContributors {

        guard let step = step as? DemoStep else { return .none }

        switch step {
        case .moviesAreRequired:
            return navigateToMovieListScreen()
        case .movieIsPicked(let movieId):
            return navigateToMovieDetailScreen(with: movieId)
        case .castIsPicked(let castId):
            return navigateToCastDetailScreen(with: castId)
        default:
            return .none
        }
    }

    private func navigateToMovieListScreen() -> FlowContributors {
        return .one(flowContributor: .contribute(withNextPresentable: rootViewController, withNextStepper: rootViewController.viewModel))
    }

    private func navigateToMovieDetailScreen (with movieId: Int) -> FlowContributors {
        let viewController = MovieDetailViewController.instantiate(withViewModel: MovieDetailViewModel(withMovieId: movieId),
                                                                   andServices: self.services)
        viewController.title = viewController.viewModel.title
        self.rootViewController.navigationController?.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewController.viewModel))
    }

    private func navigateToCastDetailScreen (with castId: Int) -> FlowContributors {
        let viewController = CastDetailViewController.instantiate(withViewModel: CastDetailViewModel(withCastId: castId),
                                                                  andServices: self.services)
        viewController.title = viewController.viewModel.name
        self.rootViewController.navigationController?.pushViewController(viewController, animated: true)
        return .none
    }
}
