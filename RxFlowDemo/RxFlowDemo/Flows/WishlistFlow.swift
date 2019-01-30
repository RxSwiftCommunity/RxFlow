//
//  WishlistFlow.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-09-05.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class WishlistFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController = UINavigationController()
    private let wishlistStepper: WishlistStepper
    private let services: AppServices

    init(withServices services: AppServices, andStepper stepper: WishlistStepper) {
        self.services = services
        self.wishlistStepper = stepper
    }

    deinit {
        print("\(type(of: self)): \(#function)")
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
        case .settingsAreRequired:
            return navigateToSettings()
        case .settingsAreComplete:
            self.rootViewController.presentedViewController?.dismiss(animated: true)
            return .none
        case .aboutIsRequired:
            return self.navigateToAbout()
        case .aboutIsComplete:
            self.rootViewController.presentedViewController?.dismiss(animated: true)
            return .none
        default:
            return .none
        }
    }

    private func navigateToMovieListScreen() -> FlowContributors {
        let viewController = WishlistViewController.instantiate(withViewModel: WishlistViewModel(), andServices: self.services)
        viewController.title = "Wishlist"
        self.rootViewController.pushViewController(viewController, animated: true)
        if let navigationBarItem = self.rootViewController.navigationBar.items?[0] {
            navigationBarItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "settings"),
                                                                style: UIBarButtonItem.Style.plain,
                                                                target: self.wishlistStepper,
                                                                action: #selector(WishlistStepper.settingsAreRequired)),
                                                animated: false)
            navigationBarItem.setLeftBarButton(UIBarButtonItem(title: "Logout",
                                                               style: UIBarButtonItem.Style.plain,
                                                               target: self,
                                                               action: #selector(WishlistFlow.logoutIsRequired)),
                                               animated: false)
        }
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: CompositeStepper(steppers: [viewController.viewModel,
                                                                                                                                   viewController])))
    }

    private func navigateToMovieDetailScreen (with movieId: Int) -> FlowContributors {
        let viewController = MovieDetailViewController.instantiate(withViewModel: MovieDetailViewModel(withMovieId: movieId),
                                                                   andServices: self.services)
        viewController.title = viewController.viewModel.title

        self.rootViewController.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewController.viewModel))
    }

    private func navigateToCastDetailScreen (with castId: Int) -> FlowContributors {
        let viewController = CastDetailViewController.instantiate(withViewModel: CastDetailViewModel(withCastId: castId),
                                                                  andServices: self.services)
        viewController.title = viewController.viewModel.name
        self.rootViewController.pushViewController(viewController, animated: true)
        return .none
    }

    private func navigateToSettings() -> FlowContributors {
        let settingsStepper = SettingsStepper()
        let settingsFlow = SettingsFlow(withServices: self.services, andStepper: settingsStepper)

        Flows.whenReady(flow1: settingsFlow) { [unowned self] (root: UISplitViewController) in
            self.rootViewController.present(root, animated: true)
        }
        return .one(flowContributor: .contribute(withNextPresentable: settingsFlow, withNextStepper: settingsStepper))
    }

    private func navigateToAbout() -> FlowContributors {
        let viewController = SettingsAboutViewController.instantiate()
        self.rootViewController.present(viewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewController))
    }

    @objc func logoutIsRequired() {
        self.services.preferencesService.setNotOnboarded()
    }
}

class WishlistStepper: Stepper {

    let steps = PublishRelay<Step>()

    @objc func settingsAreRequired() {
        self.steps.accept(DemoStep.settingsAreRequired)
    }
}
