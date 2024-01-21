//
//  MovieDetailsCoordinator.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 21/01/2024.
//

import Foundation
import XCoordinator
import Combine
enum MovieDetailsRoute: Route {
    case close
}

final class MovieDetailsCoordinator: ViewCoordinator<MovieDetailsRoute> {
    typealias RouteHandler = (MovieDetailsRoute) -> Void
    private let nextRouteHandler: RouteHandler

    init(
        movieId: String,
       routeHandler: @escaping RouteHandler
    ) {
        self.nextRouteHandler = routeHandler
        let viewController = MovieDetailsViewController()

        super.init(rootViewController: viewController)

        let movieProvider:MoviesProvider = MoviesProviderImpl(network: NetworkManager())
        
        viewController.viewModel = MovieDetailsViewModelImpl(
            movieId: movieId,
            movieProvider: movieProvider,
            router: strongRouter
        )
    }

    override func prepareTransition(for route: RouteType) -> TransitionType {
        nextRouteHandler(route)
        return .none()
    }
}
