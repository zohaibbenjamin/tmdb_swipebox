//
//  UIBarButton+Publisher.swift
//  tmdb_swipebox
//
//  Created by Zohaib Benjamin on 21/01/2024.
//

import Combine
import UIKit

public extension UIBarButtonItem {
    /// A publisher which emits whenever this UIBarButtonItem is tapped.
    var tapPublisher: AnyPublisher<Void, Never> {
        Publishers.ControlTarget(
            control: self,
            addTargetAction: { control, target, action in
                control.target = target
                control.action = action
            },
            removeTargetAction: { control, _, _ in
                control?.target = nil
                control?.action = nil
            }
        )
        .eraseToAnyPublisher()
    }
}


public extension Combine.Publishers {
    /// A publisher which wraps objects that use the Target & Action mechanism,
    /// for example - a UIBarButtonItem which isn't KVO-compliant and doesn't use UIControlEvent(s).
    ///
    /// Instead, you pass in a generic Control, and two functions:
    /// One to add a target action to the provided control, and a second one to
    /// remove a target action from a provided control.
    struct ControlTarget<Control: AnyObject>: Publisher {
        // swiftlint:disable:next nesting
        public typealias Output = Void
        // swiftlint:disable:next nesting
        public typealias Failure = Never

        private unowned let control: Control
        private let addTargetAction: (Control, AnyObject, Selector) -> Void
        private let removeTargetAction: (Control?, AnyObject, Selector) -> Void

        /// Initialize a publisher that emits a Void whenever the
        /// provided control fires an action.
        ///
        /// - parameter control: UI Control.
        /// - parameter addTargetAction: A function which accepts the Control, a Target and a Selector and
        ///                              responsible to add the target action to the provided control.
        /// - parameter removeTargetAction: A function which accepts the Control, a Target and a Selector and it
        ///                                 responsible to remove the target action from the provided control.
        public init(
            control: Control,
            addTargetAction: @escaping (Control, AnyObject, Selector) -> Void,
            removeTargetAction: @escaping (Control?, AnyObject, Selector) -> Void
        ) {
            self.control = control
            self.addTargetAction = addTargetAction
            self.removeTargetAction = removeTargetAction
        }

        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(subscriber: subscriber,
                                            control: control,
                                            addTargetAction: addTargetAction,
                                            removeTargetAction: removeTargetAction)

            subscriber.receive(subscription: subscription)
        }
    }
}


private extension Combine.Publishers.ControlTarget {
    private final class Subscription<S: Subscriber, Control: AnyObject>: Combine.Subscription where S.Input == Void {
        private var subscriber: S?
        private weak var control: Control?

        private let removeTargetAction: (Control?, AnyObject, Selector) -> Void

        init(
            subscriber: S,
            control: Control,
            addTargetAction: @escaping (Control, AnyObject, Selector) -> Void,
            removeTargetAction: @escaping (Control?, AnyObject, Selector) -> Void
        ) {
            self.subscriber = subscriber
            self.control = control
            self.removeTargetAction = removeTargetAction

            addTargetAction(control, self, #selector(handleAction))
        }

        func request(_: Subscribers.Demand) {
            // We don't care about the demand at this point.
            // As far as we're concerned - The control's target events are endless until it is deallocated.
        }

        func cancel() {
            subscriber = nil
            removeTargetAction(control, self, #selector(handleAction))
        }

        @objc private func handleAction() {
            _ = subscriber?.receive(())
        }
    }
}


public extension Publisher {
    /// Should be used instead of system subscribe for correct memory management
    func publish<S>(to subscriber: S) -> AnyCancellable where S: Subscriber & Cancellable, S.Input == Self.Output, Self.Failure == S.Failure {
        subscribe(subscriber)
        return AnyCancellable(subscriber)
    }
}

public extension Publisher where Self.Failure == Never {
    func publish(to subject: CurrentValueSubject<Output, Failure>) -> AnyCancellable {
        sink { value in
            subject.send(value)
        }
    }

    func publish(to subject: PassthroughSubject<Output, Failure>) -> AnyCancellable {
        sink { value in
            subject.send(value)
        }
    }
}
