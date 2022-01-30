import XCTest
import Combine
@testable import Flow

final class FlowTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testCartSubmissionFlow_Enum_SuccessfulSubmission() throws {

        let expectation = XCTestExpectation()

        let cart = Mocks.Cart(
            type: .none,
            items: [],
            summary: .none,
            payment: .none
        )

        CartSubmissionFlow_Enum
            .executeFrom(.submit(cart, .none))
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("Unexpected error: \(error)")
                }
            } receiveValue: { receipt in
                print("Flow successfuly completed, receipt: \(receipt)")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }

    func testCartSubmissionFlow_Enum_FailedOnCheckout() throws {

        let expectation = XCTestExpectation()

        let cart = Mocks.Cart(
            type: .none,
            items: [],
            summary: .none,
            payment: .none
        )

        CartSubmissionFlow_Enum
            .executeFrom(.submit(cart, .checkout(NSError(domain: "FailedOnCheckout", code: 0, userInfo: .none))))
            .sink { completion in
                if case let .failure(error) = completion {
                    switch error {
                    case .canceled:
                        XCTFail("Unexpected error: \(error)")

                    case let .failed(error):
                        let error = error as NSError
                        guard error.domain == "FailedOnCheckout", error.code == 0 else {
                            XCTFail("Unexpected error: \(error)")
                            return
                        }
                        expectation.fulfill()

                    case .completedWithUnexpectedResult:
                        XCTFail("Unexpected error: \(error)")
                    }
                }
            } receiveValue: { receipt in
                XCTFail("Flow completed successfully. Error expected")
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }

    func testCartSubmissionFlow_Enum_CanceledOnProvidePaymentDetails() throws {

        let expectation = XCTestExpectation()

        let cart = Mocks.Cart(
            type: .none,
            items: [],
            summary: .none,
            payment: .none
        )

        CartSubmissionFlow_Enum
            .executeFrom(.submit(cart, .providePaymentDetails(FlowInterruptionReason.canceled)))
            .sink { completion in
                if case let .failure(error) = completion {
                    switch error {
                    case .canceled:
                        expectation.fulfill()

                    case let .failed(error):
                        XCTFail("Unexpected error: \(error)")

                    case .completedWithUnexpectedResult:
                        XCTFail("Unexpected error: \(error)")
                    }
                }
            } receiveValue: { receipt in
                XCTFail("Flow completed successfully. Error expected")
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }

    func testCartSubmissionFlow_Enum_ExecutedFromPaymentDetails() throws {

        let expectation = XCTestExpectation()

        let cart = Mocks.Cart(
            type: .none,
            items: [],
            summary: .none,
            payment: .none
        )

        CartSubmissionFlow_Enum
            .executeFrom(.providePaymentDetails(cart, .none))
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("Unexpected error: \(error)")
                }
            } receiveValue: { receipt in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }

    func testCartSubmissionFlow_Struct_SuccessfulSubmission() throws {

        let expectation = XCTestExpectation()

        let cart = Mocks.Cart(
            type: .none,
            items: [],
            summary: .none,
            payment: .none
        )

        CartSubmissionFlow_Struct
            .executeFrom(.init(state: .submit(cart, .none)))
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("Unexpected error: \(error)")
                }
            } receiveValue: { receipt in
                print("Flow successfuly completed, receipt: \(receipt)")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }

    func testCartSubmissionFlow_Struct_FailedOnCheckout() throws {

        let expectation = XCTestExpectation()

        let cart = Mocks.Cart(
            type: .none,
            items: [],
            summary: .none,
            payment: .none
        )

        CartSubmissionFlow_Struct
            .executeFrom(.init(state: .submit(cart, .checkout(NSError(domain: "FailedOnCheckout", code: 0, userInfo: .none)))))
            .sink { completion in
                if case let .failure(error) = completion {
                    switch error {
                    case .canceled:
                        XCTFail("Unexpected error: \(error)")

                    case let .failed(error):
                        let error = error as NSError
                        guard error.domain == "FailedOnCheckout", error.code == 0 else {
                            XCTFail("Unexpected error: \(error)")
                            return
                        }
                        expectation.fulfill()

                    case .completedWithUnexpectedResult:
                        XCTFail("Unexpected error: \(error)")
                    }
                }
            } receiveValue: { receipt in
                XCTFail("Flow completed successfully. Error expected")
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }

    func testCartSubmissionFlow_Struct_CanceledOnProvidePaymentDetails() throws {

        let expectation = XCTestExpectation()

        let cart = Mocks.Cart(
            type: .none,
            items: [],
            summary: .none,
            payment: .none
        )

        CartSubmissionFlow_Struct
            .executeFrom(.init(state: .submit(cart, .providePaymentDetails(FlowInterruptionReason.canceled))))
            .sink { completion in
                if case let .failure(error) = completion {
                    switch error {
                    case .canceled:
                        expectation.fulfill()

                    case let .failed(error):
                        XCTFail("Unexpected error: \(error)")

                    case .completedWithUnexpectedResult:
                        XCTFail("Unexpected error: \(error)")
                    }
                }
            } receiveValue: { receipt in
                XCTFail("Flow completed successfully. Error expected")
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }

    func testCartSubmissionFlow_Struct_ExecutedFromPaymentDetails() throws {

        let expectation = XCTestExpectation()

        let cart = Mocks.Cart(
            type: .none,
            items: [],
            summary: .none,
            payment: .none
        )

        CartSubmissionFlow_Struct
            .executeFrom(.init(state: .providePaymentDetails(cart, .none)))
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("Unexpected error: \(error)")
                }
            } receiveValue: { receipt in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }
}
