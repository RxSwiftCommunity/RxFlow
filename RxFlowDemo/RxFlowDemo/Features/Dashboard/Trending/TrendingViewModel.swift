//
//  TrendingViewModel.swift
//  RxFlowDemo
//
//  Created by Li Hao Lai on 29/9/20.
//  Copyright © 2020 RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxFlow
import RxSwift
import RxCocoa

class TrendingViewModel: ViewModel, Stepper {
    let steps = PublishRelay<Step>()
}
