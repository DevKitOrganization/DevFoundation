//
//  OneShotLiveQueryResultUpdates.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 11/24/2026.
//

import Foundation

/// A sequence that produces a query fragment’s results from a results producer once.
///
/// The sequence’s iterator gets results from the results producer in its first call to `next()`, so cancelling the task
/// that’s iterating the sequence cancels result production. If the task is already cancelled, the iterator throws a
/// `CancellationError` without calling the results producer.
struct OneShotLiveQueryResultUpdates<ResultsProducer>: AsyncSequence, Sendable
where ResultsProducer: LiveQueryResultsProducer {
    typealias Element = ResultsProducer.Results
    typealias Failure = any Error


    /// The results producer that produces the query fragment’s results.
    let resultsProducer: ResultsProducer

    /// The query fragment whose results are produced.
    let queryFragment: String


    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(resultsProducer: resultsProducer, queryFragment: queryFragment)
    }
}


extension OneShotLiveQueryResultUpdates {
    /// The iterator for one-shot result updates.
    struct AsyncIterator: AsyncIteratorProtocol {
        typealias Element = ResultsProducer.Results
        typealias Failure = any Error


        /// The results producer, or `nil` if the iterator has already produced results.
        var resultsProducer: ResultsProducer?

        /// The query fragment whose results are produced.
        let queryFragment: String


        mutating func next() async throws -> ResultsProducer.Results? {
            guard let resultsProducer else {
                return nil
            }

            self.resultsProducer = nil
            try Task.checkCancellation()
            return try await resultsProducer.results(forQueryFragment: queryFragment)
        }
    }
}
