//
//  ViewModelBased.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-12-04.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import UIKit
import Reusable

protocol ViewModelBased: class {
    associatedtype ViewModel

    var viewModel: ViewModel { get set }
}

extension ViewModelBased where Self: StoryboardBased & UIViewController {
    static func instantiate (with viewModel: ViewModel) -> Self {
        let viewController = Self.instantiate()
        viewController.viewModel = viewModel
        return viewController
    }
}
