//
//  CustomActivityIndicator.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 21/01/2024.
//
import UIKit

class CustomActivityIndicatorView: UIView {

    private let activityIndicatorView = UIActivityIndicatorView(style: .large)

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        layer.cornerRadius = 10

        // Configure the activity indicator
        activityIndicatorView.color = UIColor.white
        addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func startAnimating() {
        activityIndicatorView.startAnimating()
    }

    func stopAnimating() {
        activityIndicatorView.stopAnimating()
        removeFromSuperview()
    }
}
