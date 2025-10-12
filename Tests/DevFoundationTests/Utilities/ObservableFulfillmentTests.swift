//
//  ObservableFulfillmentTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/12/25.
//

import DevFoundation
import DevTesting
import Foundation
import Synchronization
import Testing


struct ObservationFulfillmentTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    // MARK: - Non-throwing version

    @Test
    mutating func conditionAlreadyTrue() async {
        // set up an observable state with condition already true
        let state = ObservableState()
        state.flag = true
        let expectedValue = randomInt(in: .min ... .max)

        // exercise the function with a condition that is already true
        let result = await observableFulfillment {
            state.flag
        } whileExecuting: {
            expectedValue
        }

        // expect the function to return the body's result
        #expect(result == expectedValue)
    }


    @Test
    mutating func conditionBecomesTrueDuringExecution() async {
        // set up an observable state with condition initially false
        let state = ObservableState()
        let expectedValue = randomInt(in: .min ... .max)

        // exercise the function with a body that changes the condition to true
        let result = await observableFulfillment {
            state.flag
        } whileExecuting: {
            try? await Task.sleep(for: .milliseconds(100))
            state.flag = true
            return expectedValue
        }

        // expect the function to return the body's result and condition to be true
        #expect(result == expectedValue)
        #expect(state.flag == true)
    }


    @Test
    mutating func multiplePropertyChangesBeforeConditionBecomesTrue() async {
        // set up an observable state with a condition that requires value to reach threshold
        let state = ObservableState()
        let threshold = randomInt(in: 3 ... 5)
        let expectedValue = randomInt(in: .min ... .max)

        // exercise the function with a condition that becomes true after multiple changes
        let result = await observableFulfillment {
            state.value >= threshold
        } whileExecuting: {
            for i in 1 ... threshold {
                try? await Task.sleep(for: .milliseconds(100))
                state.value = i
            }
            return expectedValue
        }

        // expect the function to return the body's result and value to equal threshold
        #expect(result == expectedValue)
        #expect(state.value == threshold)
    }


    // MARK: - Throwing version

    @Test
    mutating func throwingConditionAlreadyTrue() async throws {
        // set up an observable state with condition already true
        let state = ObservableState()
        state.flag = true
        let expectedValue = randomInt(in: 0 ... .max)

        // exercise the function with a condition that is already true
        let error = randomError()
        let result = try await observableFulfillment {
            state.flag
        } whileExecuting: {
            // This will never happen
            if expectedValue < 0 {
                throw error
            }

            return expectedValue
        }

        // expect the function to return the body's result
        #expect(result == expectedValue)
    }


    @Test
    mutating func throwingConditionBecomesTrueDuringExecution() async throws {
        // set up an observable state with condition initially false
        let state = ObservableState()
        let expectedValue = randomInt(in: .min ... .max)

        // exercise the function with a body that changes the condition to true
        let result = try await observableFulfillment {
            state.flag
        } whileExecuting: {
            try await Task.sleep(for: .milliseconds(100))
            state.flag = true
            return expectedValue
        }

        // expect the function to return the body's result and condition to be true
        #expect(result == expectedValue)
        #expect(state.flag == true)
    }


    @Test
    mutating func bodyThrowsError() async throws {
        // set up an observable state with condition that will become true
        let state = ObservableState()
        let expectedError = MockError(id: randomInt(in: .min ... .max))

        // exercise the function with a body that throws an error
        await #expect(throws: expectedError) {
            try await observableFulfillment {
                state.flag
            } whileExecuting: {
                try await Task.sleep(for: .milliseconds(100))
                state.flag = true
                throw expectedError
            }
        }
    }


    @Test
    mutating func conditionThrowsError() async throws {
        // set up an observable state that can throw
        let state = ObservableState()
        let expectedError = MockError(id: randomInt(in: .min ... .max))
        state.errorToThrow = expectedError
        let expectedValue = randomInt(in: 0 ... .max)

        // exercise the function with a condition that throws an error
        await #expect(throws: expectedError) {
            try await observableFulfillment {
                try state.throwingFlag
            } whileExecuting: {
                // This will never happen
                if expectedValue < 0 {
                    throw expectedError
                }

                return expectedValue
            }
        }
    }


    // MARK: - Autoclosure Variants

    @Test
    mutating func autoclosureNonThrowingVariant() async {
        // set up an observable state with condition already true
        let state = ObservableState()
        state.flag = true
        let expectedValue = randomInt(in: .min ... .max)

        // exercise the autoclosure variant
        let result = await observableFulfillment(of: state.flag) {
            expectedValue
        }

        // expect the function to return the body's result
        #expect(result == expectedValue)
    }


    @Test
    mutating func autoclosureThrowingVariant() async throws {
        // set up an observable state with condition already true
        let state = ObservableState()
        state.flag = true
        let expectedValue = randomInt(in: 0 ... .max)

        // exercise the autoclosure variant
        let error = randomError()
        let result = try await observableFulfillment(of: state.throwingFlag) {
            // This will never happen
            if expectedValue < 0 {
                throw error
            }

            return expectedValue
        }

        // expect the function to return the body's result
        #expect(result == expectedValue)
    }
}


@Observable
private final class ObservableState: @unchecked Sendable {
    struct MutableState {
        var flag: Bool = false
        var value: Int = 0
        var errorToThrow: (any Error)?
    }


    let mutableState: Mutex<MutableState> = .init(.init())


    var flag: Bool {
        get {
            access(keyPath: \.flag)
            return mutableState.withLock { $0.flag }
        }

        set {
            withMutation(keyPath: \.flag) {
                mutableState.withLock { $0.flag = newValue }
            }
        }
    }


    var value: Int {
        get {
            access(keyPath: \.value)
            return mutableState.withLock { $0.value }
        }

        set {
            withMutation(keyPath: \.value) {
                mutableState.withLock { $0.value = newValue }
            }
        }
    }


    var errorToThrow: (any Error)? {
        get {
            access(keyPath: \.errorToThrow)
            return mutableState.withLock { $0.errorToThrow }
        }

        set {
            withMutation(keyPath: \.errorToThrow) {
                mutableState.withLock { $0.errorToThrow = newValue }
            }
        }
    }


    var throwingFlag: Bool {
        get throws {
            access(keyPath: \.errorToThrow)
            if let error = errorToThrow {
                throw error
            }

            access(keyPath: \.flag)
            return flag
        }
    }
}
