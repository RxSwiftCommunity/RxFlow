//
//  CastsService.swift
//  RxFlowDemo
//
//  Created by Li Hao Lai on 2/10/20.
//  Copyright © 2020 RxSwiftCommunity. All rights reserved.
//

import Foundation

protocol HasCastsService {
    var castsService: CastsService { get }
}

class CastsService {
    func allCast() -> [Cast] {
        CastsRepository.casts
    }
}
