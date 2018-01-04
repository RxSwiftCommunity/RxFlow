//
//  MovieDetailViewModel.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-12-03.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import RxFlow

class MovieDetailViewModel: Stepper {

    let casts: [CastViewModel]
    let title: String
    let description: String
    let year: String
    let director: String
    let writer: String
    let budget: String
    let image: String

    init(withService service: MoviesService, andMovieId movieId: Int) {

        let movie = service.movie(forId: movieId)

        self.casts = service.casts(for: movie).map({ (cast) -> CastViewModel in
            return CastViewModel (id: cast.id, name: cast.name, image: cast.image)
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

    func pick (castId: Int) {
        self.step.accept(DemoStep.castPicked(withCastId: castId))
    }
}
