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
    case newsDetail(String)
}

class AppCoordinator: NavigationCoordinator<AppRoute> {

    // MARK: Initialization

    init(
    ) {
        super.init(initialRoute: .PopularMovies)
    }

    // MARK: Overrides

    override func prepareTransition(for route: AppRoute) -> NavigationTransition {
        switch route {
        case let .PopularMovies:
            
        let coordinator = PopularMoviesCoordinator()
            return .push(coordinator)
            
        case .newsDetail(let news):
            return .multiple(
                .dismissAll(),
                .popToRoot()
               // deepLink(AppRoute.home(HomePageCoordinator().strongRouter),
                       //  HomeRoute.news,
                        // NewsRoute.newsDetail(news))
            )
        }
    }

    // MARK: Methods

    func notificationReceived() {
        self.trigger(.newsDetail("news"))
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
