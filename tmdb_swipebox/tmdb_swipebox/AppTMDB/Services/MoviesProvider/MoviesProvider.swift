//
//  MoviesProvider.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 21/01/2024.
//
import Combine
import Foundation

protocol MoviesProvider {
    func getMovies(
        query: String
    ) -> AnyPublisher<Movies, Error>
    func searchMovies(
        query: String
    ) -> AnyPublisher<Movies, Error>
}

struct MoviesProviderImpl {
    let network: MovieNetwork

    init(network: NetworkManager) {
        self.network = MovieNetwork(networkService: network)
    }
}

extension MoviesProviderImpl: MoviesProvider {
    func searchMovies(query: String) -> AnyPublisher<Movies, Error> {
        network.searchMovies(query: query)
        .mapError { $0 as Error }
        .eraseToAnyPublisher()
    }
    
    func getMovies(
        query: String
    ) -> AnyPublisher<Movies, Error> {
        network.getMovies(query: query)
        .mapError { $0 as Error }
        .eraseToAnyPublisher()
    }
}
