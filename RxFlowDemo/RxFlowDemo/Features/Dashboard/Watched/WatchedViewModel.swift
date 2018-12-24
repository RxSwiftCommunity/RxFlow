//
//  WatchedViewModel.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-11-16.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxFlow
import RxSwift
import RxCocoa

class WatchedViewModel: ServicesViewModel, Stepper {

    typealias Services = HasMoviesService

    private(set) var movies = [MovieViewModel]()
    let steps = PublishRelay<Step>()

    var services: Services! {
        didSet {
            // we can do some data refactoring in order to display things exactly the way we want (this is the aim of a ViewModel)
            self.movies = self.services.moviesService.watchedMovies().map({ (movie) -> MovieViewModel in
                return MovieViewModel(id: movie.id, title: movie.title, image: movie.image)
            })
        }
    }

    public func pick (movieId: Int) {
        self.steps.accept(DemoStep.moviePicked(withMovieId: movieId))
    }
}
