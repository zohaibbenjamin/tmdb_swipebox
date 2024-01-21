//
//  MergeSink.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 20/01/2024.
//

import Combine

@available(iOS 13.0, *)
public extension Combine.Subscribers {
    /// Use to connect reactive UI publisher to ViewModel Subscriber
    /// Storing result subscription in bag is mandatory
    class MergeSink<InputType>: Subscriber, Cancellable {
        private let inputHandler: (InputType) -> Void
        private var subscriptions = [Subscription]()

        public init(inputHandler: @escaping (InputType) -> Void) {
            self.inputHandler = inputHandler
        }

        public func receive(subscription: Subscription) {
            subscriptions.append(subscription)
            subscription.request(.unlimited)
        }

        public func receive(_ input: InputType) -> Subscribers.Demand {
            inputHandler(input)
            return .unlimited
        }

        public func receive(completion _: Subscribers.Completion<Never>) {
            // We should not cancel subscriptions on any actions from publishers
        }

        public func cancel() {
            subscriptions.forEach { $0.cancel() }
            subscriptions.removeAll()
        }
    }
}

public extension Subscribers.MergeSink {
    func map<MappedInput>(_ mappingClosure: @escaping (MappedInput) -> Input) -> Subscribers.MergeSink<MappedInput> {
        Subscribers.MergeSink<MappedInput> { [weak self] mappedValue in
            _ = self?.receive(mappingClosure(mappedValue))
        }
    }
}
