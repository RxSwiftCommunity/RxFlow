//
//  SettingsAboutViewController.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-11-14.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import UIKit
import Reusable
import RxFlow
import RxCocoa

class SettingsAboutViewController: UIViewController, StoryboardBased, Stepper {

    let steps = PublishRelay<Step>()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func done(_ sender: UIButton) {
        self.steps.accept(DemoStep.aboutIsComplete)
    }
}
