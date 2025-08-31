//
//  Response.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import Foundation

extension SimulatedURLRequestLoader {
    /// A template for creating successful HTTP responses.
    ///
    /// `SuccessResponseTemplate` encapsulates the components needed to create a successful HTTP response: status code,
    /// headers, and body data. It is used internally by the built-in response generators to construct `HTTPURLResponse`
    /// instances.
    ///
    /// You will rarely need to create a success response template unless you are implementing a custom response
    /// generator.
    public struct SuccessResponseTemplate: Sendable {
        /// The response’s status code.
        public let statusCode: HTTPStatusCode

        /// The response’s header items.
        public let headerItems: Set<HTTPHeaderItem>

        /// The response’s body.
        public let body: Data


        /// Creates a new success response template.
        ///
        /// - Parameters:
        ///   - statusCode: The response’s status code.
        ///   - headerItems: The response’s header items.
        ///   - body: The response’s body.
        public init(
            statusCode: HTTPStatusCode,
            headerItems: Set<HTTPHeaderItem>,
            body: Data
        ) {
            self.statusCode = statusCode
            self.headerItems = headerItems
            self.body = body
        }


        /// Creates a response for the specified request template.
        ///
        /// The response uses the template’s values and the request’s URL to create the response.
        ///
        /// - Parameter requestComponents: The components of the request being loaded.
        /// - Returns: The response body and a URL response generated from the template’s values.
        ///   Returns `nil` if an `HTTPURLResponse` could not be created.
        public func response(for requestComponents: RequestComponents) -> (Data, URLResponse) {
            let httpURLResponse = HTTPURLResponse(
                url: requestComponents.url,
                statusCode: statusCode.rawValue,
                httpVersion: nil,
                headerFields: Dictionary(
                    headerItems.map { ($0.field.rawValue, $0.value) },
                    uniquingKeysWith: { $1 }
                )
            )!

            return (body, httpURLResponse)
        }
    }
}
