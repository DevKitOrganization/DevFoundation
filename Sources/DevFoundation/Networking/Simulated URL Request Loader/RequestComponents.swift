//
//  RequestComponents.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import Foundation

extension SimulatedURLRequestLoader {
    /// The parsed components of a URL request used for condition evaluation.
    ///
    /// `RequestComponents` extracts and structures the key components of a `URLRequest` to make them easily accessible
    /// for request condition evaluation. This includes the HTTP method, URL components, headers, and request body.
    ///
    /// Request components are automatically created by the ``SimulatedURLRequestLoader`` when processing requests. They
    /// provide a convenient interface for request conditions and response generators to examine request details without
    /// needing to parse the original `URLRequest` directly.
    public struct RequestComponents: Hashable, Sendable {
        /// The request’s header items.
        public let headerItems: Set<HTTPHeaderItem>

        /// The request’s HTTP method.
        public let httpMethod: HTTPMethod

        /// The request’s URL.
        ///
        /// This URL is guaranteed to be absolute.
        public let url: URL

        /// The request’s URL components.
        public let urlComponents: URLComponents

        /// The URL request from which these components were parsed.
        public let urlRequest: URLRequest


        /// Creates new request components by parsing the specified URL request.
        ///
        /// Returns `nil` if a URL, URL components, or HTTP method could not be parsed from the request.
        ///
        /// - Parameter urlRequest: The request from which to parse components.
        public init?(urlRequest: URLRequest) {
            guard
                let url = urlRequest.url?.absoluteURL,
                let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let httpMethod = urlRequest.httpMethod.flatMap(HTTPMethod.init)
            else {
                return nil
            }

            self.headerItems = Set(urlRequest.httpHeaderItems)
            self.httpMethod = httpMethod
            self.url = url
            self.urlComponents = urlComponents
            self.urlRequest = urlRequest
        }


        /// The request’s HTTP body.
        ///
        /// If the URL request had a `nil` HTTP body, returns an empty `Data` instance.
        public var body: Data {
            urlRequest.httpBody ?? Data()
        }
    }
}
