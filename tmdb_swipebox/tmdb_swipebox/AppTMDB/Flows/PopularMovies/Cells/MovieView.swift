//
//  MovieView.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 20/01/2024.
//

import UIKit
import TinyConstraints
import Then
import SDWebImage

class MovieView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(with movie: Movie){
        titleLabel.text = movie.title
        if movie.voteAverage < 1 {
            ratingView.isHidden = true
        }
        else {
            ratingView.isHidden = false
            ratingLabel.text =  String(format: "%.1f", movie.voteAverage)
        }
        guard movie.genreIds?.count ?? 0 > 0 else { return }
        dateLabel.text = movie.genreIds?.description
        
        guard let moviePoster = movie.poster else {
            posterImageView.image = .placeholder
            return
        }
        posterImageView.sd_setImage(with: URL(string:ApiConstants.smallImageUrl+(moviePoster)), placeholderImage: .placeholder)
        
    }
    
    
    func configureUI(){
        self.view.backgroundColor = .white
        mainView.addTo(view).do {
            $0.backgroundColor = .background
            $0.topToSuperview(offset:0)
            $0.bottomToSuperview(offset:-20)
            $0.leftToSuperview(offset: 20)
            $0.layer.cornerRadius = 12
            $0.rightToSuperview()
            
        }
        posterImageView.addTo(mainView).do {
            $0.image = .placeholder
            $0.contentMode = .scaleAspectFit
            $0.topToSuperview(offset:10)
            $0.bottomToSuperview(offset: -10)
            $0.leadingToSuperview(offset: -20)
            $0.width(100)
            
        }
        
        titleLabel.addTo(mainView).do {
            $0.topToSuperview(offset: 20)
            $0.leadingToTrailing(of: posterImageView,offset: 20)
            $0.trailingToSuperview(offset: 10)
            $0.numberOfLines = 3
            $0.font = .boldSystemFont(ofSize: 18)
            $0.textColor = .primary
            $0.text = ""
            $0.trailingToSuperview(offset: -10)
        }
        
        dateLabel.addTo(mainView).do {
            $0.bottomToSuperview(offset: -10)
            $0.leadingToSuperview(offset: 100)
            $0.trailingToSuperview(offset: 10)
            $0.textColor = .darkGray
            $0.text = ""
            $0.textAlignment = .left
            $0.numberOfLines = 2
        }
        
        ratingView.addTo(mainView).do {
            $0.width(80)
            $0.height(30)
            $0.layer.cornerRadius = 15
            $0.backgroundColor = .secondary
            $0.centerX(to: posterImageView)
            $0.bottomToSuperview(offset: -14)
        }
        
        ratingImageView.addTo(ratingView).do {
            $0.width(20)
            $0.height(20)
            $0.image = .starFill
            $0.contentMode = .scaleAspectFit
            $0.centerYToSuperview()
            $0.leadingToSuperview(offset:10)
        }
        
        ratingLabel.addTo(ratingView).do {
            $0.text = ""
            $0.textAlignment = .right
            $0.textColor = .primary
            $0.font = .boldSystemFont(ofSize: 14)
            $0.trailingToSuperview(offset:20)
            $0.centerYToSuperview()
            $0.height(25)
        }
        
    }
    
    
    private let mainView = UIView()
    private let posterImageView = UIImageView()
    private let ratingView = UIView()
    private let ratingImageView = UIImageView()
    private let ratingLabel = UILabel()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private var gradientLayer: CAGradientLayer!
}
