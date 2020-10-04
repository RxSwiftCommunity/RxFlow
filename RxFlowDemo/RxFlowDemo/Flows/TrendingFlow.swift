//
//  TrendingFlow.swift
//  RxFlowDemo
//
//  Created by Li Hao Lai on 29/9/20.
//  Copyright © 2020 RxSwiftCommunity. All rights reserved.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class TrendingFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController = UINavigationController()
    private let services: AppServices
    private let trendingStepper: TrendingStepper

    init(withServices services: AppServices, andStepper stepper: TrendingStepper) {
        self.services = services
        self.trendingStepper = stepper
    }

    deinit {
        print("\(type(of: self)): \(#function)")
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? DemoStep else { return .none }

        switch step {
        case .trendingsAreRequired:
            return navigateToTrendingScreen()
        default:
            return .none
        }
    }

    private func navigateToTrendingScreen() -> FlowContributors {
        let viewController = TrendingViewController.instantiate(withViewModel: TrendingViewModel())
        viewController.title = "Trending"
        self.rootViewController.pushViewController(viewController, animated: true)

        let trendingFlow = TrendingMovieFlow(withServices: self.services)
        let castListFlow = CastListFlow(withServices: self.services)

        Flows.use(trendingFlow, castListFlow, when: .ready) { trendingRoot, castListRoot in
            viewController.nestedViewControllers = [trendingRoot, castListRoot]
        }

        return .multiple(flowContributors: [.contribute(withNextPresentable: trendingFlow,
                                                        withNextStepper: OneStepper(withSingleStep: DemoStep.moviesAreRequired),
                                                        allowStepWhenDismissed: true),
                                            .contribute(withNextPresentable: castListFlow,
                                                        withNextStepper: OneStepper(withSingleStep: DemoStep.castListAreRequired),
                                                        allowStepWhenDismissed: true)])
    }
}

class TrendingStepper: Stepper {

    let steps = PublishRelay<Step>()

    var initialStep: Step {
        return DemoStep.trendingsAreRequired
    }
}
