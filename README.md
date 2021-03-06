# Flow
Generic definition of the flow where next iteration determines based on the result of previously executed iteration.

There are just a few components of the flow defined:
 - the `FlowProtocol` itself. Defines an interface of a flow
 - the `UserStoryProtocol`. Represents a single iteration of the flow
 - flow's `Completion`. Represents the type of the result that flow provides upon successful completion
 - `FlowInterruptionReason`. Represents the reason of Flow failure

On top of basic definition of the Flow there is a `CombineFlowProtocol` that extends  `FlowProtocol` by defining a version of the Flow where Completion is represented as AnyPublisher of `CompletionResult` that failure type is `FlowInterruptionReason`.

Extensions of `CombineFlowProtocol` provides default implementation of the flow, where result of the flow execution is an instance of the flow itself. Userful when flow defined as an Swift enum.

Minimal implementation of the flow requires the following definitions and method implementations:
- typealias UserStory == `Self`. The flow conforms to UserStoryProtocol. That is necessary for the flow to decide which step should be executed next (in execute method)
- typealias CompletionResult = `{{TYPE}}`. Type of result of the flow
- typealias Completion == `AnyPublisher<CompletionResult, FlowInterruptionReason>`. Type of the flow completion 
- `func tryMap() throws -> CompletionResult`. Method that maps result of the flow into the type defined as CompletionResult
- `func execute() -> AnyPublisher<UseeStory?, Error>`. Method that provides the next step of the flow

Upon flow failure the error of FlowInterruptionReason type throws and it  should be handled by the flow caller. 
For canceling the flow - throw an FlowInterruptionReason.canceled. In current implementation canceling the flow won't provide any details about what UserStory throwed cancelation. 
If you need to provide more details you should define type, conforming to  Swift.Error, and use FlowInterruptionReason.failed(T##CustomError) to pass the necessary details. 

Simple template of the flow looks like following example:

```
enum TestFlow: CombineFlowProtocol, UserStoryProtocol {
    typealias CompletionResult = T##Some
    typealias Completion = AnyPublisher<CompletionResult, FlowInterruptionReason>
    typealias UserStory = Self

    case case1(Parameters)
    case case2(Parameters)

    func execute() -> AnyPublisher<UserStory?, Error> {
        switch self {
        case let .case1(parameters):
            fatalError(TODO: perform action, map result into UserStory)

        case let case2(parameters):
            fatalError(TODO: return nil if this is the final step of the flow)
        }
    }

    func tryMap() throws -> CompletionResult {
        fatalError("TODO: map result of the flow into Some, or throw an error .completedWithUnexpectedResult")
    }
}
```

Executing the flow:
```
    ...
    .flatMap { parameters in
        TestFlow.executeFrom(.case1(parameters))
    }
    .map { result in 
        Result<T##Some, FlowInterruptionReason>.success(result)
    }
    .tryCatch { error in 
        assertionFailure("TODO: handle an error")
        return Just(Result<T##Some, FlowInterruptionReason>.failure(error))
    }
    ...
```

For more example please refer to the Tests/FlowTests folder where you can find an example of the cart submission flow implemented using Swift enum and struct.
