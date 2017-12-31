//
//  WishlistFlow.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-09-05.
//  Copyright © 2017 Warp Factor. All rights reserved.
//

import RxFlow
import RxSwift
import UIKit

class WishlistWarp: Flow {

    var root: UIViewController {
        return self.rootViewController
    }

    private let rootViewController = UINavigationController()
    private let wishlistStepper: WishlistStepper
    private let service: MoviesService

    init(withService service: MoviesService, andStepper stepper: WishlistStepper) {
        self.service = service
        self.wishlistStepper = stepper
    }

    func navigate(to step: Step) -> [Flowable] {

        guard let step = step as? DemoStep else { return Flowable.noFlow }

        switch step {

        case .movieList:
            return navigateToMovieListScreen()
        case .moviePicked(let movieId):
            return navigateToMovieDetailScreen(with: movieId)
        case .castPicked(let castId):
            return navigateToCastDetailScreen(with: castId)
        case .settings:
            return navigateToSettings()
        default:
            return Flowable.noFlow
        }

    }

    private func navigateToMovieListScreen () -> [Flowable] {
        let viewModel = WishlistViewModel(with: self.service)
        let viewController = WishlistViewController.instantiate(with: viewModel)
        viewController.title = "Wishlist"
        self.rootViewController.pushViewController(viewController, animated: true)
        if let navigationBarItem = self.rootViewController.navigationBar.items?[0] {
            navigationBarItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "settings"),
                                                                style: UIBarButtonItemStyle.plain,
                                                                target: self.wishlistStepper,
                                                                action: #selector(WishlistStepper.settings)),
                                                animated: false)
        }
        return [Flowable(nextPresentable: viewController, nextStepper: viewModel)]
    }

    private func navigateToMovieDetailScreen (with movieId: Int) -> [Flowable] {
        let viewModel = MovieDetailViewModel(withService: self.service, andMovieId: movieId)
        let viewController = MovieDetailViewController.instantiate(with: viewModel)
        viewController.title = viewModel.title
        self.rootViewController.pushViewController(viewController, animated: true)
        return [Flowable(nextPresentable: viewController, nextStepper: viewModel)]
    }

    private func navigateToCastDetailScreen (with castId: Int) -> [Flowable] {
        let viewModel = CastDetailViewModel(withService: self.service, andCastId: castId)
        let viewController = CastDetailViewController.instantiate(with: viewModel)
        viewController.title = viewModel.name
        self.rootViewController.pushViewController(viewController, animated: true)
        return Flowable.noFlow
    }

    private func navigateToSettings () -> [Flowable] {
        let settingsStepper = SettingsStepper()
        let settingsFlow = SettingsFlow(withService: self.service, andStepper: settingsStepper)
        Flows.whenReady(flow: settingsFlow, block: { [unowned self] (root: UISplitViewController) in
            self.rootViewController.present(root, animated: true)
        })
        return [Flowable(nextPresentable: settingsFlow, nextStepper: settingsStepper)]
    }
}

class WishlistStepper: Stepper {

    init() {
        self.step.onNext(DemoStep.movieList)
    }

    @objc func settings () {
        self.step.onNext(DemoStep.settings)
    }
}
