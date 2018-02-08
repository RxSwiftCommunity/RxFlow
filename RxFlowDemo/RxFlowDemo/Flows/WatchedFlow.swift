//
//  WishlistFlow.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-09-05.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxFlow
import UIKit

class WatchedFlow: Flow {

    var root: UIViewController {
        return self.rootViewController
    }

    private let rootViewController = UINavigationController()
    private let service: MoviesService

    init(withService service: MoviesService) {
        self.service = service
    }

    func navigate(to step: Step) -> NextFlowItems {

        guard let step = step as? DemoStep else { return NextFlowItems.stepNotHandled }

        switch step {

        case .movieList:
            return navigateToMovieListScreen()
        case .moviePicked(let movieId):
            return navigateToMovieDetailScreen(with: movieId)
        case .castPicked(let castId):
            return navigateToCastDetailScreen(with: castId)
        default:
            return NextFlowItems.stepNotHandled
        }
    }

    private func navigateToMovieListScreen () -> NextFlowItems {
        let viewController = WatchedViewController.instantiate(withViewModel: WatchedViewModel(), andServices: self.service)
        viewController.title = "Watched"
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: viewController, nextStepper: viewController.viewModel))
    }

    private func navigateToMovieDetailScreen (with movieId: Int) -> NextFlowItems {
        let viewController = MovieDetailViewController.instantiate(withViewModel: MovieDetailViewModel(withMovieId: movieId), andServices: self.service)
        viewController.title = viewController.viewModel.title
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: viewController, nextStepper: viewController.viewModel))
    }

    private func navigateToCastDetailScreen (with castId: Int) -> NextFlowItems {
        let viewController = CastDetailViewController.instantiate(withViewModel: CastDetailViewModel(withCastId: castId), andServices: self.service)
        viewController.title = viewController.viewModel.name
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.none
    }
}
