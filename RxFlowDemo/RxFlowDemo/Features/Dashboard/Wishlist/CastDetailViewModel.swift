//
//  CastViewModel.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-12-06.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

class CastDetailViewModel: ServicesViewModel {

    var services: MoviesService! {
        didSet {
            let cast = self.services.cast(forId: castId)
            self.name = cast.name
            self.image = cast.image
            self.bio = cast.bio
        }
    }

    private(set) var name = ""
    private(set) var image = ""
    private(set) var bio = ""

    public let castId: Int

    init(withCastId id: Int) {
        self.castId = id
    }
}
