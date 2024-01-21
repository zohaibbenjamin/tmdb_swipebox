//
//  AppCoordinator.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 20/01/2024.
//

import UIKit
import XCoordinator

enum AppRoute: Route {
    case PopularMovies
    case movieDetails(Movie)
    case goBack
}

class AppCoordinator: NavigationCoordinator<AppRoute> {
    private var nextRouteHandler: RouteHandler?
    public typealias RouteHandler = (AppRoute) -> Void

    // MARK: Initialization
    init() {
        super.init(initialRoute: .PopularMovies)
    }

    // MARK: Overrides

    override func prepareTransition(for route: AppRoute) -> NavigationTransition {
        switch route {
        case .PopularMovies:
            
            let coordinator = PopularMoviesCoordinator(){[weak self] childRoute in
                switch childRoute {
                case let .movieDetails(movie):
                    self?.trigger(.movieDetails(movie))
                }
            }
            return .push(coordinator)
            
        case let .movieDetails(movie):
            let coordinator = MovieDetailsCoordinator(movieId: movie.id.description){ [weak self] childRoute in
                switch childRoute {
                case .close:
                    self?.trigger(.goBack)
                }
            }
            return .push(coordinator)
        case .goBack:
            return .pop()
        }
    }
}


extension Transition {

    static func presentFullScreen(_ presentable: Presentable, animation: Animation? = nil) -> Transition {
        presentable.viewController?.modalPresentationStyle = .fullScreen
        return .present(presentable, animation: animation)
    }

    static func dismissAll() -> Transition {
        return Transition(presentables: [], animationInUse: nil) { rootViewController, options, completion in
            guard let presentedViewController = rootViewController.presentedViewController else {
                completion?()
                return
            }
            presentedViewController.dismiss(animated: options.animated) {
                Transition.dismissAll()
                    .perform(on: rootViewController, with: options, completion: completion)
            }
        }
    }

}
