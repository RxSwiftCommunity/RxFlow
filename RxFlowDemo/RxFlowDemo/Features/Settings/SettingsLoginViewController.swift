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
import RxFlow

class SettingsLoginViewController: UIViewController, StoryboardBased, Stepper {

    @IBOutlet weak var proceedButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        proceedButton.rx.tap
            .map { DemoStep.loginIsComplete }
            .bind(to: self.step)
            .disposed(by: disposeBag)
    }

}
