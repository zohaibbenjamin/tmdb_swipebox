//
//  MovieDetailsViewController.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 21/01/2024.
//

import Combine
import UIKit
import TinyConstraints
import Then
import SDWebImage


class MovieDetailsViewController: UIViewController {

    // MARK: - Public
    var viewModel: MovieDetailsViewModel!

    func configureBindings() {
        guard let viewModel = viewModel else { return }
        
        viewModel.isLoading
            .sink{ isLoading in
               if isLoading {
                   self.customActivityIndicatorView.frame = self.view.bounds
                   self.view.addSubview(self.customActivityIndicatorView)
                   self.customActivityIndicatorView.startAnimating()
                }
                else {
                    self.customActivityIndicatorView.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .sink{ error in
                self.showToast(message: error.localizedDescription)
            }
            .store(in: &cancellables)
        
        navigationItem.leftBarButtonItem?.tapPublisher
            .publish(to: viewModel.onBack)
            .store(in: &cancellables)

        
        viewModel.moviePublisher
            .sink { movie in
                self.movieDetail = movie
            }
            .store(in: &cancellables)
    }

    func configureUI() {
        view.backgroundColor = .background
        configureNavigation()
        
        moviePosterContainer.addTo(view).do {
            $0.topToSuperview(offset:20,usingSafeArea: true)
            $0.leadingToSuperview()
            $0.trailingToSuperview()
            $0.height(300)
        }
        
        moviePoster.addTo(moviePosterContainer).do {
            $0.edgesToSuperview()
            $0.image = .placeholder
            $0.contentMode = .scaleAspectFit
        }
        
        overViewLabel.addTo(view).do {
            $0.topToBottom(of: moviePosterContainer,offset: 20)
            $0.leadingToSuperview(offset: 20)
            $0.trailingToSuperview(offset: 20)
            $0.numberOfLines = 0
            $0.textAlignment = .center
            
        }
        
    }

    private func configureNavigation() {
        title = "TM DB Movie Details"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.rightBarButtonItem = nil
        let button = UIBarButtonItem(image: .arrowLeft, style: .plain, target: nil, action: nil)
        button.tintColor = .black
        navigationItem.leftBarButtonItem = button
    }

    private func updateDetails(with movie: Movie?) {
        guard let movie else { return }
        
        overViewLabel.text = movie.overview
        
        guard let movieBanner = movie.poster else {
            moviePoster.image = .placeholder
            return
        }
        moviePoster.sd_setImage(with: URL(string:ApiConstants.smallImageUrl+(movieBanner)), placeholderImage: .placeholder)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureBindings()
        viewModel.onViewLoaded.send()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Private
    private let customActivityIndicatorView = CustomActivityIndicatorView()
    private var overViewLabel = UILabel()
    private var moviePoster = UIImageView()
    private var moviePosterContainer = UIView()
    private var cancellables = Set<AnyCancellable>()
    private var movieDetail: Movie? {
        didSet {
           updateDetails(with: movieDetail)
        }
    }

}
