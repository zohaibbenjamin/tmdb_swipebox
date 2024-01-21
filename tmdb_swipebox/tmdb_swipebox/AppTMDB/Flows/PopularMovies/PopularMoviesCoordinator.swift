//
//  PopularMoviesCoordinator.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 20/01/2024.
//

import Foundation
import Combine
import XCoordinator

enum PopularMoviesRoute: Route {
    case close
}

final class PopularMoviesCoordinator: ViewCoordinator<PopularMoviesRoute> {
    typealias RouteHandler = (PopularMoviesRoute) -> Void

   // private let nextRouteHandler: RouteHandler

    init(
       // routeHandler: @escaping RouteHandler
    ) {
      //  nextRouteHandler = routeHandler
        let viewController = PopularMoviesViewController()

        super.init(rootViewController: viewController)

        let movieProvider:MoviesProvider = MoviesProviderImpl(network: NetworkManager())
        
        viewController.viewModel = PopularMoviesViewModelImpl(
            movieProvider: movieProvider, router: strongRouter
        )
    }

    override func prepareTransition(for route: RouteType) -> TransitionType {
       // nextRouteHandler(route)
        return .none()
    }
}
