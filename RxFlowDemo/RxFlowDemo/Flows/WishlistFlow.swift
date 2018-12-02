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
    private let services: AppServices

    init(withServices services: AppServices, andStepper stepper: WishlistStepper) {
        self.services = services
        self.wishlistStepper = stepper
    }

    deinit {
        print("\(type(of: self)): \(#function)")
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? DemoStep else { return .none }

        switch step {
        case .movieList:
            return navigateToMovieListScreen()
        case .moviePicked(let movieId):
            return navigateToMovieDetailScreen(with: movieId)
        case .castPicked(let castId):
            return navigateToCastDetailScreen(with: castId)
        case .settings:
            return navigateToSettings()
        case .settingsIsComplete:
            return self.dismissModal()
        case .qrCodeReader(let completionBlock):
            return self.navigateToQrCodeReader(with: completionBlock)
        case .qrCodeDone:
            return self.dismissModal()
        default:
            return .none
        }
    }

    private func dismissModal () -> NextFlowItems {
        self.rootViewController.presentedViewController?.dismiss(animated: true)
        return .none
    }

    private func navigateToQrCodeReader (with completionBlock: @escaping (String) -> Void) -> NextFlowItems {
        let viewController = QRCodeReaderViewController()
        viewController.completionBlock = completionBlock
        self.rootViewController.present(viewController, animated: true)
        return .one(flowItem: NextFlowItem(nextPresentable: viewController, nextStepper: viewController))
    }

    private func navigateToMovieListScreen() -> NextFlowItems {
        let viewController = WishlistViewController.instantiate(withViewModel: WishlistViewModel(), andServices: self.services)
        viewController.title = "Wishlist"
        self.rootViewController.pushViewController(viewController, animated: true)
        if let navigationBarItem = self.rootViewController.navigationBar.items?[0] {
            navigationBarItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "settings"),
                                                                style: UIBarButtonItem.Style.plain,
                                                                target: self.wishlistStepper,
                                                                action: #selector(WishlistStepper.settings)),
                                                animated: false)
        }
        return .one(flowItem: NextFlowItem(nextPresentable: viewController,
                                           nextStepper: CompositeStepper(steppers: [viewController, viewController.viewModel])))
    }

    private func navigateToMovieDetailScreen (with movieId: Int) -> NextFlowItems {
        let viewController = MovieDetailViewController.instantiate(withViewModel: MovieDetailViewModel(withMovieId: movieId),
                                                                   andServices: self.services)
        viewController.title = viewController.viewModel.title

        self.rootViewController.pushViewController(viewController, animated: true)
        return .one(flowItem: NextFlowItem(nextPresentable: viewController,
                                           nextStepper: viewController.viewModel))
    }

    private func navigateToCastDetailScreen (with castId: Int) -> NextFlowItems {
        let viewController = CastDetailViewController.instantiate(withViewModel: CastDetailViewModel(withCastId: castId),
                                                                  andServices: self.services)
        viewController.title = viewController.viewModel.name
        self.rootViewController.pushViewController(viewController, animated: true)
        return .none
    }

    private func navigateToSettings() -> NextFlowItems {
        let settingsStepper = SettingsStepper()
        let settingsFlow = SettingsFlow(withServices: self.services, andStepper: settingsStepper)

        Flows.whenReady(flow1: settingsFlow) { [unowned self] (root: UISplitViewController) in
            self.rootViewController.present(root, animated: true)
        }

        return .one(flowItem: NextFlowItem(nextPresentable: settingsFlow,
                                           nextStepper: settingsStepper))
    }
}

class WishlistStepper: Stepper, HasDisposeBag {

    init() {
        self.step.accept(DemoStep.movieList)
    }

    @objc func settings() {
        self.step.accept(DemoStep.settings)
    }
}
