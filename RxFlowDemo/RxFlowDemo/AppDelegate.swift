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
    var coordinator = FlowCoordinator()
    let moviesService = MoviesService()
    let preferencesService = PreferencesService()
    lazy var appServices = {
        return AppServices(moviesService: self.moviesService, preferencesService: self.preferencesService)
    }()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        guard let window = self.window else { return false }

        self.coordinator.rx.willNavigate.subscribe(onNext: { (flow, step) in
            print ("will navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: self.disposeBag)

        self.coordinator.rx.didNavigate.subscribe(onNext: { (flow, step) in
            print ("did navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: self.disposeBag)

        let appFlow = AppFlow(services: self.appServices)

        Flows.whenReady(flow1: appFlow) { root in
            window.rootViewController = root
            window.makeKeyAndVisible()
        }

        self.coordinator.coordinate(flow: appFlow, with: AppStepper(withServices: self.appServices))

        return true
    }

}

struct AppServices: HasMoviesService, HasPreferencesService {
    let moviesService: MoviesService
    let preferencesService: PreferencesService
}
