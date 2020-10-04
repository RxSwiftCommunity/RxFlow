//
//  CastListViewModel.swift
//  RxFlowDemo
//
//  Created by Li Hao Lai on 30/9/20.
//  Copyright © 2020 RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxFlow
import RxSwift
import RxCocoa

class CastListViewModel: ServicesViewModel, Stepper {
    let steps = PublishRelay<Step>()
    typealias Services = HasCastsService

    private(set) var casts: [CastViewModel]

    var services: Services! {
        didSet {
            self.casts = self.services.castsService.allCast().map({ (cast) -> CastViewModel in
                return CastViewModel(id: cast.id, name: cast.name, image: cast.image)
            })
        }
    }

    init() {
        self.casts = [CastViewModel]()
    }

    public func pick(castId: Int) {
        self.steps.accept(DemoStep.castIsPicked(withId: castId))
    }
}
