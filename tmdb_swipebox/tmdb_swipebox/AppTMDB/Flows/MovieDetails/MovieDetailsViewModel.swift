//
//  MovieDetailsViewModel.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 21/01/2024.
//

import Combine
import XCoordinator

protocol MovieDetailsViewModel {
    var onViewLoaded: Subscribers.MergeSink<Void> { get }
    var onBack: Subscribers.MergeSink<Void> { get }
    var errorPublisher: AnyPublisher<Error, Never> { get }
    var isLoading: AnyPublisher<Bool, Never> { get }
    var moviePublisher: AnyPublisher<Movie,Never> { get }
}

final class MovieDetailsViewModelImpl {
  

    private let router: StrongRouter<MovieDetailsRoute>
    private let movieProvider: MoviesProvider
    
    private var cancellableBag = Set<AnyCancellable>()
    private var movieSubject = PassthroughSubject<Movie, Never>()
    private var loadingSubject = CurrentValueSubject<Bool, Never>(false)
    private var errorSubject = PassthroughSubject<Error, Never>()
    private var movieId: String?
   
    init(
        movieId: String,
        movieProvider: MoviesProvider,
        router: StrongRouter<MovieDetailsRoute>
    ) {
        self.router = router
        self.movieId = movieId
        self.movieProvider = movieProvider
    }
}

extension MovieDetailsViewModelImpl: MovieDetailsViewModel {
    var moviePublisher: AnyPublisher<Movie, Never> {
        movieSubject.eraseToAnyPublisher()
    }
    
    var onViewLoaded: Subscribers.MergeSink<Void> {
        .init {
            [weak self] _ in
            guard let self = self else { return }
            guard let movieId = movieId else { return }
            loadingSubject.send(true)
            movieProvider.getMovieDetails(movieId: movieId)
                .sink { completion in
                    self.loadingSubject.send(false)
                    switch completion {
                    case .finished:
                        print("done")
                    case let .failure(error):
                        self.errorSubject.send(error)
                    }
                } receiveValue: { [weak self] movie in
                    guard let self = self else { return }
                    movieSubject.send(movie)
                }
                .store(in: &cancellableBag)
        }
    }

    var onBack: Subscribers.MergeSink<Void> {
        .init {
            [weak self] _ in
            guard let self = self else { return }
            self.router.trigger(.close)
        }
    }

    var errorPublisher: AnyPublisher<Error, Never> {
        errorSubject.eraseToAnyPublisher()
    }


    var isLoading: AnyPublisher<Bool, Never> {
        loadingSubject.eraseToAnyPublisher()
    }
}
