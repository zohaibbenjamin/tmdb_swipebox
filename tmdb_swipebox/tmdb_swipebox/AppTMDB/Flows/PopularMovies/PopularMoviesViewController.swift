//
//  PopularMoviesViewController.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 20/01/2024.
//

import Combine
import UIKit
import TinyConstraints
import Then


class PopularMoviesViewController: UIViewController {

    // MARK: - Public
    var viewModel: PopularMoviesViewModel!

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
        
        viewModel.moviesPublisher
            .sink { movies in
                self.popularMovies = movies.items
            }
            .store(in: &cancellables)
    }

    func configureUI() {
        view.backgroundColor = .background
        configureNavigation()
        navigationItem.searchController = self.searchController
        searchController.isActive = true

        moviesTableView.addTo(view).do {
            $0.topToSuperview(offset: 20, usingSafeArea: true)
            $0.bottomToSuperview(usingSafeArea: true)
            $0.leadingToSuperview()
            $0.trailingToSuperview()
        }
        
    }

    private func configureNavigation() {
        title = "TM DB Popular Movies"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func setupTableView() {
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        moviesTableView.separatorStyle = .none
        moviesTableView.register(PopularMovieCell.self, forCellReuseIdentifier: PopularMovieCell.identifier)

    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        configureUI()
        configureBindings()
        viewModel.onViewLoaded.send()
       
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Private
    private var moviesTableView = UITableView()
    private var cancellables = Set<AnyCancellable>()
    private var popularMovies: [Movie] = [] {
        didSet {
            moviesTableView.reloadData()
        }
    }
    private let searchSubject = PassthroughSubject<String, Never>()
    private let customActivityIndicatorView = CustomActivityIndicatorView()
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .label
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.accessibilityIdentifier = "SearchParam"
        return searchController
    }()

}

extension PopularMoviesViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return popularMovies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PopularMovieCell.identifier, for: indexPath) as? PopularMovieCell
        else {
            fatalError("Unable to dequeue CustomTableViewCell")
        }
        let movie = popularMovies[indexPath.row]
            cell.setup(with: movie)
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.onClickMovie.send(popularMovies[indexPath.row])
    }
    
    

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        200
    }
}

extension PopularMoviesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchMovie.send(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.onViewLoaded.send()
    }
}
