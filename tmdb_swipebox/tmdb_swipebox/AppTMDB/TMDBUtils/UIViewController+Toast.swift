//
//  UIViewController+Toast.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 21/01/2024.
//

import UIKit

extension UIViewController {

    func showToast(message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textAlignment = .center
        toastLabel.textColor = UIColor.white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.numberOfLines = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true

        let maxWidthPercentage: CGFloat = 0.8
        let maxWidth = view.bounds.width * maxWidthPercentage
        let labelSize = toastLabel.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))

        toastLabel.frame = CGRect(x: 0, y: 0, width: labelSize.width + 20, height: labelSize.height + 20)
        toastLabel.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height - 100)

        view.addSubview(toastLabel)

        UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }) { _ in
            toastLabel.removeFromSuperview()
        }
    }
}
