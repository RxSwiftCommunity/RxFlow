//
//  WishlistViewModel.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-12-03.
//  Copyright © 2017 Warp Factor. All rights reserved.
//

import RxSwift
import RxFlow

class WishlistViewModel: Stepper {

    let movies: [MovieViewModel]

    init(with service: MoviesService) {
        // we can do some data refactoring in order to display things exactly the way we want (this is the aim of a ViewModel)
        self.movies = service.wishlistMovies().map({ (movie) -> MovieViewModel in
            return MovieViewModel(id: movie.id, title: movie.title, image: movie.image)
        })
    }

    public func pick (movieId: Int) {
        self.step.onNext(DemoStep.moviePicked(withMovieId: movieId))
    }
}
