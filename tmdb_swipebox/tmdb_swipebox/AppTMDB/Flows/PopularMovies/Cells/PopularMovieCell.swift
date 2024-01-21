//
//  PopularMovieCell.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 20/01/2024.
//


import UIKit
import TinyConstraints
import Then

class PopularMovieCell: UITableViewCell {
    static let identifier = "PopularMovieCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }

    required init?(coder _: NSCoder) {
        preconditionFailure("Required Init not available")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func setup(with movie: Movie) {
        movieView.setup(with: movie)
    }

    // MARK: Private

    private let movieView = MovieView()
    private let mainView = UIView()
    private let label = UILabel()
    
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .white
        
        mainView.addTo(contentView).do {
            $0.layer.cornerRadius = 12
            $0.topToSuperview(offset: 10)
            $0.leadingToSuperview(offset: 20)
            $0.trailingToSuperview(offset: 20)
            $0.bottomToSuperview(offset: -10)
        }
        movieView.addTo(mainView).do {
            $0.edgesToSuperview()
        }
    }
    
    
}
