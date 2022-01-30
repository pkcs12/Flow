//
//  CartSubmissionFlow_Struct.swift
//
//
//  Created by Valerii Lider on 1/23/22.
//

import Foundation
import Combine
@testable import Flow

/// Example of the flow implemented using Swift struct.
///
/// In this example the result of the successful cart submission is a `Receipt` struct.
///
/// Flow could fail with `FlowInterruptionReason` that should be handled by the flow caller using `.tryCatch` or `.catch`.
///
/// Flow steps here represented by `State` enum cases. `submit` is the entry point of the flow.
/// But the flow could be executed from any given step, as every case has it's own data set, sufficient for performing it.
/// That means that if the flow was abandoned at `confirm` step, it could be recreated and carried from the same step.
///
/// Flow completes when `execute` method returns `nil` which means - no more steps to execute.
/// In this example, the successful flow completion suppose to end on `receipt(_, _)` case.
/// Flow execution already implemented in the protocol extensions, so the only things left for building the flow are:
/// * define steps of the flow (cases)
/// * implement `tryMap` method that maps result of successfully completed flow
/// * implement `execute` method that returns the next step of the flow
///
struct CartSubmissionFlow_Struct: CombineFlowProtocol {
    typealias CompletionResult = Mocks.Receipt
    typealias Completion = AnyPublisher<CompletionResult, FlowInterruptionReason>
    typealias UserStory = Self

    enum State {
        case submit(Mocks.Cart, Mocks.FailOn?)
        case selectType(Mocks.Cart, Mocks.FailOn?)
        case selectPickupAddress(Mocks.Cart, Mocks.FailOn?)
        case provideDeliveryInstructions(Mocks.Cart, Mocks.FailOn?)
        case providePaymentDetails(Mocks.Cart, Mocks.FailOn?)
        case confirm(Mocks.Cart, Mocks.FailOn?)
        case checkout(Mocks.Cart, Mocks.FailOn?)
        case receipt(Mocks.Cart, Mocks.FailOn?, Mocks.Receipt)
    }

    let state: State

    func tryMap() throws -> CompletionResult {
        if case let .receipt(_, _, receipt) = state {
            return receipt
        }
        throw FlowInterruptionReason.completedWithUnexpectedResult
    }
}

extension CartSubmissionFlow_Struct: UserStoryProtocol {

    func execute() -> AnyPublisher<UserStory?, Error> {
        print("Executing: \(self.state)")
        switch self.state {
        case let .submit(cart, failOn):
            return Just(.init(state: .selectType(cart, failOn)))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()

        case let .selectType(cart, failOn):
            return Mocks.SelectType(failOn: failOn)
                .execute()
                .map { isDelivery in
                    isDelivery
                        ? .init(state: .provideDeliveryInstructions(cart, failOn))
                        : .init(state: .selectPickupAddress(cart, failOn))
                }
                .eraseToAnyPublisher()

        case let .selectPickupAddress(cart, failOn):
            return Mocks.SelectPickupAddress(failOn: failOn)
                .execute()
                .map { address in cart.setType(.pickup(address)) }
                .map { .init(state: .providePaymentDetails($0, failOn)) }
                .eraseToAnyPublisher()

        case let .provideDeliveryInstructions(cart, failOn):
            return Mocks.ProvideDeliveryInstructions(failOn: failOn)
                .execute()
                .map { instructions in cart.setType(.delivery(instructions)) }
                .map { .init(state: .providePaymentDetails($0, failOn)) }
                .eraseToAnyPublisher()

        case let .providePaymentDetails(cart, failOn):
            return Mocks.ProvidePaymentDetails(failOn: failOn)
                .execute()
                .map { payment in cart.setPayment(payment) }
                .map { .init(state: .confirm($0, failOn)) }
                .eraseToAnyPublisher()

        case let .confirm(cart, failOn):
            return Mocks.Confirm(failOn: failOn)
                .execute()
                .tryMap { confirmed in
                    if confirmed {
                        return .init(state: .checkout(cart, failOn))
                    }
                    throw FlowInterruptionReason.canceled
                }
                .eraseToAnyPublisher()

        case let .checkout(cart, failOn):
            return Mocks.Checkout(failOn: failOn)
                .execute()
                .map { receipt in .init(state: .receipt(cart, failOn, receipt)) }
                .eraseToAnyPublisher()

        case .receipt:
            return Just(Self?.none)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
