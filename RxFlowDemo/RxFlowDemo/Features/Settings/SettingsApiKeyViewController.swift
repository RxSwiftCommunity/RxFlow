//
//  DashboardViewController1.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-07-26.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import UIKit
import Reusable
import RxFlow
import RxSwift
import RxCocoa

class SettingsApiKeyViewController: UIViewController, StoryboardBased, ViewModelBased {

    var viewModel: SettingsApiKeyViewModel!

    @IBOutlet private weak var proceedButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _ = proceedButton.rx.tap
            .take(until: self.rx.deallocating)
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.setApiKey()
            })
    }
}
