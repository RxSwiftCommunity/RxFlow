//
//  CastViewModel.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-12-06.
//  Copyright © 2017 Warp Factor. All rights reserved.
//

class CastDetailViewModel {

    let name: String
    let image: String
    let bio: String

    init(withService service: MoviesService, andCastId castId: Int) {
        let cast = service.cast(forId: castId)
        self.name = cast.name
        self.image = cast.image
        self.bio = cast.bio
    }
}
