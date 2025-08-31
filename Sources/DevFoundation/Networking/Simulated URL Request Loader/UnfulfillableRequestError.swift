//
//  UnfulfillableRequestError.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/24/25.
//

import Foundation

extension SimulatedURLRequestLoader {
    /// An error indicating that no responder could fulfill a request.
    ///
    /// This error is thrown by ``SimulatedURLRequestLoader`` when no configured responders are able
    /// to generate a response for a request.
    ///
    /// The error includes the request that could not be fulfilled, which can be useful for
    /// debugging.
    public struct UnfulfillableRequestError: Error, Hashable {
        /// The request that could not be fulfilled.
        public let request: URLRequest


        /// Creates a new unfulfillable request error with the specified request.
        ///
        /// - Parameter request: The request that could not be fulfilled.
        public init(request: URLRequest) {
            self.request = request
        }
    }
}
