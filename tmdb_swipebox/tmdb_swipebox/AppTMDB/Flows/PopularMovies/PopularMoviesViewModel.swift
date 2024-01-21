//
//  PopularMoviesViewModel.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 20/01/2024.
//

import Combine
import XCoordinator

protocol PopularMoviesViewModel {
    var onViewLoaded: Subscribers.MergeSink<Void> { get }
    var onBack: Subscribers.MergeSink<Void> { get }
    var isLoading: AnyPublisher<Bool, Never> { get }
    var moviesPublisher: AnyPublisher<Movies,Never> { get }
    var searchMovie: Subscribers.MergeSink<String> { get }
    
}

final class PopularMoviesViewModelImpl {
  

    private let router: StrongRouter<PopularMoviesRoute>
    private let movieProvider: MoviesProvider
    
    private var cancellableBag = Set<AnyCancellable>()
    private var moviesSubject = PassthroughSubject<Movies, Never>()
    private var loadingSubject = CurrentValueSubject<Bool, Never>(false)
    private var errorSubject = PassthroughSubject<Error, Never>()
   
   
    init(
        movieProvider: MoviesProvider,
        router: StrongRouter<PopularMoviesRoute>
    ) {
        self.router = router
        self.movieProvider = movieProvider
    }
}

extension PopularMoviesViewModelImpl: PopularMoviesViewModel {
    var searchMovie: Subscribers.MergeSink<String> {
        .init {
            [weak self] query in
            guard let self = self else { return }
            movieProvider.searchMovies(query: query)
                .sink { completion in
                    print(completion)
                } receiveValue: { [weak self] movies in
                    guard let self = self else { return }
                    moviesSubject.send(movies)
                }
                .store(in: &cancellableBag)
        }
    }
    
    var moviesPublisher: AnyPublisher<Movies, Never> {
        moviesSubject.eraseToAnyPublisher()
    }
    
  
    var onViewLoaded: Subscribers.MergeSink<Void> {
        .init {
            [weak self] _ in
            guard let self = self else { return }
            movieProvider.getMovies(query: "")
                .sink { completion in
                    print(completion)
                } receiveValue: { [weak self] movies in
                    guard let self = self else { return }
                    moviesSubject.send(movies)
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
