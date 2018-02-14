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

    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController = UINavigationController()
    private let wishlistStepper: WishlistStepper
    private let service: MoviesService

    init(withService service: MoviesService, andStepper stepper: WishlistStepper) {
        self.service = service
        self.wishlistStepper = stepper
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
        case .settings:
            return navigateToSettings()
        case .settingsDone:
            self.rootViewController.presentedViewController?.dismiss(animated: true)
            return NextFlowItems.none
        default:
            return NextFlowItems.stepNotHandled
        }
    }

    private func navigateToMovieListScreen () -> NextFlowItems {
        let viewController = WishlistViewController.instantiate(withViewModel: WishlistViewModel(), andServices: self.service)
        viewController.title = "Wishlist"
        self.rootViewController.pushViewController(viewController, animated: true)
        if let navigationBarItem = self.rootViewController.navigationBar.items?[0] {
            navigationBarItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "settings"),
                                                                style: UIBarButtonItemStyle.plain,
                                                                target: self.wishlistStepper,
                                                                action: #selector(WishlistStepper.settings)),
                                                animated: false)
        }
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: viewController, nextStepper: viewController.viewModel))
    }

    private func navigateToMovieDetailScreen (with movieId: Int) -> NextFlowItems {
        let viewController = MovieDetailViewController.instantiate(withViewModel: MovieDetailViewModel(withMovieId: movieId), andServices: self.service)
        viewController.title = viewController.viewModel.title
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: viewController, nextStepper: viewController.viewModel))
    }

    private func navigateToCastDetailScreen (with castId: Int) -> NextFlowItems {
        let viewController = CastDetailViewController().instantiate(withViewModel: CastDetailViewModel(withCastId: castId), andServices: self.service)
        viewController.title = viewController.viewModel.name
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.none
    }

    private func navigateToSettings () -> NextFlowItems {
        let settingsStepper = SettingsStepper()
        let settingsFlow = SettingsFlow(withService: self.service, andStepper: settingsStepper)
        Flows.whenReady(flow1: settingsFlow, block: { [unowned self] (root: UISplitViewController) in
            self.rootViewController.present(root, animated: true)
        })
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: settingsFlow, nextStepper: settingsStepper))
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
