//
//  Result+CatchingAsync.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/16/25.
//

import Foundation

extension Result {
    /// Creates a new result by evaluating a throwing async closure, capturing the returned value as a success, or any
    /// thrown error as a failure.
    ///
    /// - Parameter body: A potentially throwing closure to evaluate.
    public init(catching body: () async throws(Failure) -> Success) async {
        do {
            self = .success(try await body())
        } catch {
            self = .failure(error)
        }
    }
}
