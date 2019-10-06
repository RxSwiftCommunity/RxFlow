//
//  MovieDetailViewModel.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-12-03.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxCocoa
import RxFlow

class MovieDetailViewModel: ServicesViewModel, Stepper {

    let steps = PublishRelay<Step>()
    typealias Services = HasMoviesService

    var services: Services! {
        didSet {
            let movie = self.services.moviesService.movie(forId: movieId)

            self.casts = self.services.moviesService.casts(for: movie).map({ (cast) -> CastViewModel in
                return CastViewModel(id: cast.id, name: cast.name, image: cast.image)
            })

            self.title = movie.title
            self.description = movie.description
            self.year = "\(movie.year)"
            self.director = movie.director
            self.writer = movie.writer
            self.image = movie.image

            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = NumberFormatter.Style.currency
            currencyFormatter.locale = NSLocale.current
            self.budget = currencyFormatter.string(from: NSNumber(value: movie.budget))!
        }
    }

    private(set) var casts = [CastViewModel]()
    private(set) var title = ""
    private(set) var description = ""
    private(set) var year = ""
    private(set) var director = ""
    private(set) var writer = ""
    private(set) var budget = ""
    private(set) var image = ""

    public let movieId: Int

    init(withMovieId id: Int) {
        self.movieId = id
    }

    func pick (castId: Int) {
        self.steps.accept(DemoStep.castIsPicked(withId: castId))
    }
}
