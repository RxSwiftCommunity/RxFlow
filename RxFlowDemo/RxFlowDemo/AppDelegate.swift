//
//  AppDelegate.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-07-25.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let disposeBag = DisposeBag()
    var window: UIWindow?
    var coordinator = Coordinator()
    let movieService = MoviesService()
    lazy var mainFlow = {
        return ApiFlow(with: self.movieService)
    }()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        guard let window = self.window else { return false }

        coordinator.rx.didNavigate.subscribe(onNext: { (flow, step) in
            print ("did navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: self.disposeBag)

        coordinator.coordinate(flow: mainFlow, withStepper: OneStepper(withSingleStep: DemoStep.apiKey))
		window.rootViewController = coordinator.container
        return true
    }

}
