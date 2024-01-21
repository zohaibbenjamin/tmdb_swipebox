//
//  Subscribers+Send.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 20/01/2024.
//

import Combine

@available(iOS 13.0, *)
public extension Subscriber where Self.Input == Void {
    func send() {
        _ = receive(())
    }
}

@available(iOS 13.0, *)
public extension Subscriber {
    func send(_ input: Input) {
        _ = receive(input)
    }
}
