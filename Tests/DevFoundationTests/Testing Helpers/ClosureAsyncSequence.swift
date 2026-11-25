//
//  ClosureAsyncSequence.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 11/24/2026.
//

import Foundation

/// An async sequence whose iterator calls a closure to get each element.
///
/// Tests use this sequence to control exactly what happens each time a sequence is asked for its next element,
/// including ignoring cancellation. Because a consumer only asks for the next element after it’s handled the previous
/// one, a call to the closure also tells the test that the previous element was handled.
struct ClosureAsyncSequence<Element>: AsyncSequence, Sendable where Element: Sendable {
    typealias Failure = any Error


    /// The closure that returns each element.
    ///
    /// The closure’s parameter is the zero-based index of the call. Return `nil` to end the sequence.
    let nextElement: @Sendable (Int) async throws -> Element?


    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(nextElement: nextElement)
    }


    struct AsyncIterator: AsyncIteratorProtocol {
        typealias Failure = any Error


        let nextElement: @Sendable (Int) async throws -> Element?
        var index = 0


        mutating func next() async throws -> Element? {
            defer {
                index += 1
            }

            return try await nextElement(index)
        }
    }
}
