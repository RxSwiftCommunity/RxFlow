//
//  MoviesService.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-11-16.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

class MoviesService {

    func wishlistMovies () -> [Movie] {
        return MoviesRepository.movies.filter { !$0.watched }
    }

    func watchedMovies () -> [Movie] {
        return MoviesRepository.movies.filter { $0.watched }
    }

    func movie (forId id: Int) -> Movie {
        return MoviesRepository.movies.filter { $0.id == id }.first!
    }

    func cast (forId id: Int) -> Cast {
        return CastsRepository.casts.filter { $0.id == id }.first!
    }

    func casts (for movie: Movie) -> [Cast] {
        // Dumb condition to find the casting according to a movie
        if movie.id % 2 == 0 {
           return [CastsRepository.casts[0], CastsRepository.casts[2], CastsRepository.casts[4], CastsRepository.casts[6], CastsRepository.casts[8]]

        }
        return [CastsRepository.casts[1], CastsRepository.casts[3], CastsRepository.casts[5], CastsRepository.casts[7], CastsRepository.casts[9]]
    }
}
