//
//  WatchedViewModel.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-11-16.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxFlow
import RxSwift

class WatchedViewModel: ServicesViewModel {

    private(set) var movies = [MovieViewModel]()

    var services: MoviesService! {
        didSet {
            // we can do some data refactoring in order to display things exactly the way we want (this is the aim of a ViewModel)
            self.movies = self.services.watchedMovies().map({ (movie) -> MovieViewModel in
                return MovieViewModel(id: movie.id, title: movie.title, image: movie.image)
            })
        }
    }
}

extension WatchedViewModel: Stepper {
    public func pick (movieId: Int) {
        self.step.accept(DemoStep.moviePicked(withMovieId: movieId))
    }
}
