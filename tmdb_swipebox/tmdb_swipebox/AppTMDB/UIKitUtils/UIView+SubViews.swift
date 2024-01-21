//
//  UIView+SubViews.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 20/01/2024.
//

import UIKit

public extension UIView {
    /**
     Adds the view to a parent view.
     - Parameter parentView: The parent view to add the view to.
     - Returns: The view that was added to the parent view, with the same type as the original view.
     */
    @discardableResult
    func addTo(_ parentView: UIView) -> Self {
        parentView.addSubview(self)
        return self
    }

    /**
     Adds the view to a stack view.
     - Parameter stackView: The stack view to add the view to.
     - Returns: The view that was added to the stack view, with the same type as the original view.
     */
    @discardableResult
    func addTo(_ stackView: UIStackView) -> Self {
        stackView.addArrangedSubview(self)
        return self
    }
}

