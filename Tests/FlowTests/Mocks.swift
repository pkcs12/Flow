//
//  Mocks.swift
//
//
//  Created by Valerii Lider on 1/23/22.
//

import Foundation
import Combine
@testable import Flow

enum Mocks {

    enum FailOn {
        case submit(Error)
        case selectType(Error)
        case selectPickupAddress(Error)
        case provideDeliveryInstructions(Error)
        case providePaymentDetails(Error)
        case confirm(Error)
        case checkout(Error)
        case receipt(Error)
    }

    struct Cart {
        let type: CartType?
        let items: [Item]
        let summary: Summary?
        let payment: Payment?

        func setType(_ type: CartType) -> Self {
            .init(type: type, items: items, summary: summary, payment: payment)
        }

        func setSummary(_ summary: Summary) -> Self {
            .init(type: type, items: items, summary: summary, payment: payment)
        }

        func setPayment(_ payment: Payment) -> Self {
            .init(type: type, items: items, summary: summary, payment: payment)
        }
    }

    // cart item, for simplicity reduced to empty struct
    struct Item {
    }

    // cart summary, for simplicity reduced to empty struct
    struct Summary {
    }

    // payment details, for simplicity reduced to empty struct
    struct Payment {
    }

    // type of the cart
    enum CartType {
        case pickup(Location)
        case delivery(Instructions)
    }

    // address for pickup or delivery, simplified
    struct Location {
        let address: String
    }

    // delivery instructions
    struct Instructions {
        let location: Location
        let instructions: String
    }

    // receipt of the submission, reduced to empty struct for simplification
    struct Receipt {
    }

    // Choose if the order is fro delivery or pickup. In real flow this step will bring some UI
    // To simplify an example flow this step produces a deferred response that the cart is for pickup
    struct SelectType: UserStoryProtocol {
        let failOn: FailOn?

        func execute() -> AnyPublisher<Bool, Error> {
            Deferred {
                Future<Bool, Error> {
                    if case let .selectType(error) = failOn {
                        $0(.failure(error))
                    } else {
                        $0(.success(false))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
    }

    // Provide address for pickup. In real flow this step will bring some UI
    // To simplify an example flow this step produces a deferred response with pickup location
    struct SelectPickupAddress: UserStoryProtocol {
        let failOn: FailOn?

        func execute() -> AnyPublisher<Location, Error> {
            Deferred {
                Future<Location, Error> {
                    if case let .selectPickupAddress(error) = failOn {
                        $0(.failure(error))
                    } else {
                        $0(.success(.init(address: "Any address")))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
    }

    // Provide instructions for delivery. In real flow this step will bring some UI
    // To simplify an example flow this step produces a deferred response with delivery instructions
    struct ProvideDeliveryInstructions: UserStoryProtocol {
        let failOn: FailOn?

        func execute() -> AnyPublisher<Instructions, Error> {
            Deferred {
                Future<Instructions, Error> {
                    if case let .provideDeliveryInstructions(error) = failOn {
                        $0(.failure(error))
                    } else {
                        $0(
                            .success(
                                .init(
                                    location: .init(address: "Any address"),
                                    instructions: "delivery instructions"
                                )
                            )
                        )
                    }
                }
            }
            .eraseToAnyPublisher()
        }
    }

    // Provide payment details. In real flow this step will bring some UI
    // To simplify an example flow this step produces a deferred response with payment details
    struct ProvidePaymentDetails: UserStoryProtocol {
        let failOn: FailOn?

        func execute() -> AnyPublisher<Payment, Error> {
            Deferred {
                Future<Payment, Error> {
                    if case let .providePaymentDetails(error) = failOn {
                        $0(.failure(error))
                    } else {
                        $0(.success(.init()))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
    }

    // Provide payment details. In real flow this step will bring some UI
    // To simplify an example flow this step produces a deferred response with user confirming cart submission
    struct Confirm: UserStoryProtocol {
        let failOn: FailOn?

        func execute() -> AnyPublisher<Bool, Error> {
            Deferred {
                Future<Bool, Error> {
                    if case let .confirm(error) = failOn {
                        $0(.failure(error))
                    } else {
                        $0(.success(true))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
    }

    // Provide payment details. In real flow this step will bring some UI
    // To simplify an example flow this step produces a deferred response with successfully submitted cart receipt
    struct Checkout: UserStoryProtocol {
        let failOn: FailOn?

        func execute() -> AnyPublisher<Receipt, Error> {
            Deferred {
                Future<Receipt, Error> {
                    if case let .checkout(error) = failOn {
                        $0(.failure(error))
                    } else {
                        $0(.success(.init()))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
    }
}

