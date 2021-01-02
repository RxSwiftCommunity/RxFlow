//
//  SettingsLoginViewController.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 18-02-14.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import RxFlow

class SettingsLoginViewController: UIViewController, StoryboardBased, Stepper {

    @IBOutlet weak var proceedButton: UIButton!

    let steps = PublishRelay<Step>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _ = proceedButton.rx.tap
            .take(until: self.rx.deallocating)
            .map { DemoStep.userIsLoggedIn }
            .bind(to: self.steps)
    }

}
