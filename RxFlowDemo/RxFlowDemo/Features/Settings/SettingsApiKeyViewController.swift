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
        proceedButton.rx.tap
            .flatMap { [unowned self] in self.viewModel.setApiKey() }
            .map { $0 as Step }
            .bind(to: viewModel.step)
            .disposed(by: disposeBag)
    }
}
