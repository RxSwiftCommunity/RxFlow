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
        self.proceedButton.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.step.accept(DemoStep.loginIsComplete)
        }).disposed(by: self.disposeBag)
    }

}
