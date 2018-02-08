//
//  ApiFlow.swift
//  RxFlowDemo
//
//  Created by Jozef Matus on 01/02/2018.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import RxFlow
import RxSwift

class ApiFlow: Flow {

	var root: UIViewController {
		return self.rootViewController
	}

	private let rootViewController: UINavigationController
	private let service: MoviesService

	init(with service: MoviesService) {
		self.rootViewController = UINavigationController()
		self.service = service
	}

	func navigate(to step: Step) -> NextFlowItems {
		guard let step = step as? DemoStep else { return NextFlowItems.stepNotHandled }

		switch step {
		case .apiKey:
			return navigationToApiScreen()
		case .apiKeyIsComplete:
			return navigationToTabFlow()
		default:
			return NextFlowItems.stepNotHandled
		}
	}

	private func navigationToApiScreen () -> NextFlowItems {
		let settingsViewController = SettingsViewController.instantiate()
		rootViewController.pushViewController(settingsViewController, animated: false)
		return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: settingsViewController, nextStepper: settingsViewController))
	}

	private func navigationToTabFlow() -> NextFlowItems {
		let tabFlow = TabFlow(with: self.service)
		return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: tabFlow, nextStepper: OneStepper(withSingleStep: DemoStep.apiKeyIsComplete), isRootFlowable: true))
	}

}
