//
//  File.swift
//  
//
//  Created by Valerii Lider on 1/23/22.
//

import Foundation
import Combine

public protocol CombineFlowProtocol: FlowProtocol {
    associatedtype CompletionResult
    // tryMap is called only upon flow reports successful completion
    func tryMap() throws -> CompletionResult
    func executeFrom(_ userStory: UserStory) -> AnyPublisher<CompletionResult, FlowInterruptionReason>
}

public extension CombineFlowProtocol
    where UserStory == Self,
          UserStory.Result == AnyPublisher<UserStory?, Error>
{
    // execute the flow step by step until it returns nil, or fails with an error
    private func unfold(_ userStory: UserStory) -> AnyPublisher<UserStory, FlowInterruptionReason> {
        userStory
            .execute()
            .mapError { error -> FlowInterruptionReason in
                if let error = error as? FlowInterruptionReason {
                    return error
                }
                return FlowInterruptionReason.failed(error)
            }
            .flatMap { result -> AnyPublisher<Self, FlowInterruptionReason> in
                // execute next step
                if let result = result {
                    return unfold(result)
                }
                // complete the flow with last executed step result
                return Just(userStory)
                    .setFailureType(to: FlowInterruptionReason.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

public extension CombineFlowProtocol
    where Completion == AnyPublisher<CompletionResult, FlowInterruptionReason>,
          UserStory == Self,
          UserStory.Result == AnyPublisher<UserStory?, Error>
{
    // execute the flow and map the completion into the CompletionResult
    func executeFrom(_ userStory: UserStory) -> Completion {
        unfold(userStory)
            .flatMap { userStory -> Completion in
                do {
                    return Just(try userStory.tryMap())
                        .setFailureType(to: FlowInterruptionReason.self)
                        .eraseToAnyPublisher()
                } catch {
                    if let error = error as? FlowInterruptionReason {
                        return Fail(outputType: CompletionResult.self, failure: error)
                            .eraseToAnyPublisher()
                    }
                    return Fail(outputType: CompletionResult.self, failure: .failed(error))
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

// helper for cases when flow completes without providing any result
public extension CombineFlowProtocol
    where Completion == AnyPublisher<CompletionResult, FlowInterruptionReason>,
          CompletionResult == Void,
          UserStory == Self,
          UserStory.Result == AnyPublisher<UserStory?, Error>
{
    func executeFrom(_ userStory: UserStory) -> Completion {
        unfold(userStory)
            .map { _ in Void() }
            .eraseToAnyPublisher()
    }
}
