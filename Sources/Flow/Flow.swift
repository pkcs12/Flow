//
//  Flow.swift
//
//
//  Created by Valerii Lider on 1/23/22.
//

import Foundation

public protocol UserStoryProtocol {
    associatedtype Result
    func execute() -> Result
}

public protocol FlowProtocol {
    associatedtype Completion
    associatedtype UserStory: UserStoryProtocol
    func executeFrom(_ userStory: UserStory) -> Completion
}

public enum FlowInterruptionReason: Error {
    case canceled, failed(Error)
    case completedWithUnexpectedResult // flow is not configured correctly, completed with unexpected result
}

public extension FlowProtocol where UserStory == Self {

    static func executeFrom(_ userStory: UserStory) -> Completion {
        userStory.executeFrom(userStory)
    }
}
