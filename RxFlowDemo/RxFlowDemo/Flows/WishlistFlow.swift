//
//  WishlistFlow.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-09-05.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxFlow
import RxSwift
import UIKit

class WishlistFlow: Flow {

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

    func navigate(to step: Step) -> [NextFlowItem] {

        guard let step = step as? DemoStep else { return NextFlowItem.noNavigation }

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
            return NextFlowItem.noNavigation
        }

    }

    private func navigateToMovieListScreen () -> [NextFlowItem] {
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
        return [NextFlowItem(nextPresentable: viewController, nextStepper: viewModel)]
    }

    private func navigateToMovieDetailScreen (with movieId: Int) -> [NextFlowItem] {
        let viewModel = MovieDetailViewModel(withService: self.service, andMovieId: movieId)
        let viewController = MovieDetailViewController.instantiate(with: viewModel)
        viewController.title = viewModel.title
        self.rootViewController.pushViewController(viewController, animated: true)
        return [NextFlowItem(nextPresentable: viewController, nextStepper: viewModel)]
    }

    private func navigateToCastDetailScreen (with castId: Int) -> [NextFlowItem] {
        let viewModel = CastDetailViewModel(withService: self.service, andCastId: castId)
        let viewController = CastDetailViewController.instantiate(with: viewModel)
        viewController.title = viewModel.name
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItem.noNavigation
    }

    private func navigateToSettings () -> [NextFlowItem] {
        let settingsStepper = SettingsStepper()
        let settingsFlow = SettingsFlow(withService: self.service, andStepper: settingsStepper)
        Flows.whenReady(flow1: settingsFlow, block: { [unowned self] (root: UISplitViewController) in
            self.rootViewController.present(root, animated: true)
        })
        return [NextFlowItem(nextPresentable: settingsFlow, nextStepper: settingsStepper)]
    }
}

class WishlistStepper: Stepper, HasDisposeBag {

    init() {
        self.step.accept(DemoStep.movieList)

        // example of a periodic check of something to could lead to a global navigation action
        // for instance it could be an Interval in which we check the session validity. In case of
        // invalidity we could trigger a new Step (sessionInvalid for instance) that would lead to
        // a login popup
//        Observable<Int>.interval(5, scheduler: MainScheduler.instance).subscribe(onNext: { [unowned self] (_) in
//            self.step.accept(DemoStep.settings)
//        }).disposed(by: self.disposeBag)
    }

    @objc func settings () {
        self.step.accept(DemoStep.settings)
    }
}
