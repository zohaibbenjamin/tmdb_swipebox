//
//  MovieNetworkProvider.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 21/01/2024.
//

import Combine
import Foundation


public struct MovieNetwork {
    let networkService: NetworkManager
    func getMovies(
        query: String
    ) -> AnyPublisher<Movies, Error> {
            networkService.getDataWithQuery(endpoint: .popularMovies, parameters: [
                "api_key": ApiConstants.apiKey,
                "query": query,
                "language": Locale.preferredLanguages[0]
                ], type: Movies.self)
            .mapError({ error in
                return error
            })
            .eraseToAnyPublisher()
    }
    func searchMovies(
        query: String
    ) -> AnyPublisher<Movies, Error> {
        networkService.getDataWithQuery(endpoint: .searchPopularMovies, parameters: [
                "api_key": ApiConstants.apiKey,
                "query": query,
                "language": Locale.preferredLanguages[0]
                ], type: Movies.self)
            .mapError({ error in
                return error
            })
            .eraseToAnyPublisher()
    }
    
    func getMovieDetail(
        movieId: String?
    ) -> AnyPublisher<Movie, Error> {
        networkService.getDataWithAuthnAppendID(endpoint: .movieDetail, params: movieId, type: Movie.self)
            .mapError({ error in
                return error
            })
            .eraseToAnyPublisher()
    }
    
}
