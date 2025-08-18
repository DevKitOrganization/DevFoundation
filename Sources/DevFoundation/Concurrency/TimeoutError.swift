//
//  TimeoutError.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/18/25.
//

import Foundation

/// An error indicating that an operation timed out.
public struct TimeoutError: CustomStringConvertible, Error, Hashable {
    /// The duration after which the operation timed out.
    public let timeout: Duration


    /// Creates a new timeout error.
    ///
    /// - Parameter timeout: The duration after which the operation timed out.
    public init(timeout: Duration) {
        self.timeout = timeout
    }


    public var description: String {
        return "Operation timed out after \(timeout)"
    }
}
