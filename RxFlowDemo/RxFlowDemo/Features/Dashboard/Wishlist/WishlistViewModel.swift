//
//  WishlistViewModel.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-12-03.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxSwift
import RxFlow

class WishlistViewModel: ServicesViewModel {

    typealias Services = HasMoviesService

    private(set) var movies: [MovieViewModel]

    var services: Services! {
        didSet {
            // we can do some data refactoring in order to display things exactly the way we want (this is the aim of a ViewModel)
            self.movies = self.services.moviesService.wishlistMovies().map({ (movie) -> MovieViewModel in
                return MovieViewModel(id: movie.id, title: movie.title, image: movie.image)
            })
        }
    }

    init() {
        self.movies = [MovieViewModel]()
    }
}

extension WishlistViewModel: Stepper {
    public func pick (movieId: Int) {
        self.step.accept(DemoStep.movieIsPicked(withId: movieId))
    }
}
