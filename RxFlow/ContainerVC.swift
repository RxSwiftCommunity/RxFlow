//
//  ContainerVC.swift
//  RxFlow
//
//  Created by Jozef Matus on 01/02/2018.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import UIKit
/// Simple custom container which will hold root views
public class ContainerVC: UIViewController {

	var rootFlow: Flow?

	func set(RootFlow flow: Flow) {
		self.rootFlow = flow
		self.addChildViewController(rootFlow!.root)
		rootFlow!.root.view.frame = self.view.frame
		self.view.addSubview(rootFlow!.root.view)
		rootFlow!.root.didMove(toParentViewController: self)
	}

	func removeContent() {
		self.rootFlow?.root.willMove(toParentViewController: nil)
		self.rootFlow?.root.view.removeFromSuperview()
		self.rootFlow?.root.removeFromParentViewController()
		self.rootFlow = nil
	}
}

