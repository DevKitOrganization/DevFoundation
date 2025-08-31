//
//  ResponseGenerator.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import Foundation

extension SimulatedURLRequestLoader {
    /// A type that generates responses for simulated requests.
    ///
    /// Response generators provide the core logic for creating HTTP responses in the simulated URL request loader. They
    /// receive request components and return either a successful response tuple or an error, along with an optional
    /// delay to simulate network latency.
    ///
    /// Most users will not need to implement custom response generators, as DevFoundation provides built-in generators
    /// through the various `respond(with:...)` functions on ``SimulatedURLRequestLoader``. However, you can create
    /// custom generators for more complex scenarios, such as:
    ///
    ///   - Generating responses based on request content
    ///   - Implementing stateful response logic
    ///   - Simulating complex server behaviors
    ///
    /// ## Custom Implementation
    ///
    /// When implementing a custom response generator, return `nil` if this generator cannot or should not respond to
    /// the request. This allows responders to skip generating a response without affecting other responders.
    public protocol ResponseGenerator: Sendable {
        /// Generates a response for the given request components.
        ///
        /// - Parameter requestComponents: The components of the request to respond to.
        /// - Returns: A tuple containing the response result and delay, or `nil` if this generator cannot respond to
        ///   the request.
        func response(
            for requestComponents: RequestComponents
        ) async -> (Result<(Data, URLResponse), any Error>, delay: Duration)?
    }
}


extension SimulatedURLRequestLoader {
    /// A response generator that always responds with the same response.
    struct FixedResponseGenerator: ResponseGenerator {
        /// The result with which to respond.
        ///
        /// If the result is a success, the success response template is used to generate a response. Otherwise the
        /// result’s error is thrown.
        let result: Result<SuccessResponseTemplate, any Error>

        /// The response delay.
        let delay: Duration


        func response(
            for requestComponents: RequestComponents
        ) async -> (Result<(Data, URLResponse), any Error>, delay: Duration)? {
            do {
                let template = try result.get()
                return (.success(template.response(for: requestComponents)), delay: delay)
            } catch {
                return (.failure(error), delay: delay)
            }
        }
    }
}


extension SimulatedURLRequestLoader {
    /// Adds a responder that throws an error when its conditions are met.
    ///
    /// - Parameters:
    ///   - error: The error to throw when responding.
    ///   - delay: The delay before throwing the error. Defaults to `.zero`.
    ///   - maxResponses: The maximum number of times this responder will respond. Defaults to `1`.
    ///   - requestConditions: The conditions that must be met for this responder to activate.
    /// - Returns: The created responder.
    @discardableResult
    public func respond(
        with error: any Error,
        delay: Duration = .zero,
        maxResponses: Int? = 1,
        when requestConditions: [any RequestCondition]
    ) -> some Responder {
        let responder = Responder(
            requestConditions: requestConditions,
            responseGenerator: FixedResponseGenerator(
                result: .failure(error),
                delay: delay
            ),
            maxResponses: maxResponses
        )
        add(responder)
        return responder
    }


    /// Adds a responder that returns a response with the specified status code and body data.
    ///
    /// - Parameters:
    ///   - statusCode: The HTTP status code for the response.
    ///   - headerItems: The HTTP headers to include in the response. Defaults to an empty set.
    ///   - body: The response body data.
    ///   - delay: The delay before responding. Defaults to `.zero`.
    ///   - maxResponses: The maximum number of times this responder will respond. Defaults to `1`.
    ///   - requestConditions: The conditions that must be met for this responder to activate.
    /// - Returns: The created responder.
    @discardableResult
    public func respond(
        with statusCode: HTTPStatusCode,
        headerItems: Set<HTTPHeaderItem> = [],
        body: Data,
        delay: Duration = .zero,
        maxResponses: Int? = 1,
        when requestConditions: [any RequestCondition]
    ) -> some Responder {
        let responder = Responder(
            requestConditions: requestConditions,
            responseGenerator: FixedResponseGenerator(
                result: .success(
                    SuccessResponseTemplate(
                        statusCode: statusCode,
                        headerItems: headerItems,
                        body: body
                    )
                ),
                delay: delay
            ),
            maxResponses: maxResponses
        )
        add(responder)
        return responder
    }


    /// Adds a responder that returns a response with the specified status code and string body.
    ///
    /// - Parameters:
    ///   - statusCode: The HTTP status code for the response.
    ///   - headerItems: The HTTP headers to include in the response. Defaults to an empty set.
    ///   - body: The response body as a string.
    ///   - encoding: The string encoding to use when converting the body to data. Defaults to `.utf8`.
    ///   - delay: The delay before responding. Defaults to `.zero`.
    ///   - maxResponses: The maximum number of times this responder will respond. Defaults to `1`.
    ///   - requestConditions: The conditions that must be met for this responder to activate.
    /// - Returns: The created responder.
    @discardableResult
    public func respond(
        with statusCode: HTTPStatusCode,
        headerItems: Set<HTTPHeaderItem> = [],
        body: String,
        encoding: String.Encoding = .utf8,
        delay: Duration = .zero,
        maxResponses: Int? = 1,
        when requestConditions: [any RequestCondition]
    ) -> some Responder {
        let responder = Responder(
            requestConditions: requestConditions,
            responseGenerator: FixedResponseGenerator(
                result: .success(
                    SuccessResponseTemplate(
                        statusCode: statusCode,
                        headerItems: headerItems,
                        body: body.data(using: encoding)!
                    )
                ),
                delay: delay
            ),
            maxResponses: maxResponses
        )
        add(responder)
        return responder
    }


    /// Adds a responder that returns a response with the specified status code and encodable body.
    ///
    /// The body value will be encoded using the provided encoder. If encoding fails, this function will trap.
    ///
    /// - Parameters:
    ///   - statusCode: The HTTP status code for the response.
    ///   - headerItems: The HTTP headers to include in the response. Defaults to an empty set.
    ///   - body: The response body value to be encoded.
    ///   - encoder: The encoder to use for encoding the body. Defaults to `JSONEncoder()`.
    ///   - delay: The delay before responding. Defaults to `.zero`.
    ///   - maxResponses: The maximum number of times this responder will respond. Defaults to `1`.
    ///   - requestConditions: The conditions that must be met for this responder to activate.
    /// - Returns: The created responder.
    @discardableResult
    public func respond<Body>(
        with statusCode: HTTPStatusCode,
        headerItems: Set<HTTPHeaderItem> = [],
        body: Body,
        encoder: any TopLevelEncoder<Data> = JSONEncoder(),
        delay: Duration = .zero,
        maxResponses: Int? = 1,
        when requestConditions: [any RequestCondition]
    ) -> some Responder
    where Body: Encodable {
        let responder = Responder(
            requestConditions: requestConditions,
            responseGenerator: FixedResponseGenerator(
                result: .success(
                    SuccessResponseTemplate(
                        statusCode: statusCode,
                        headerItems: headerItems,
                        body: try! encoder.encode(body)
                    )
                ),
                delay: delay
            ),
            maxResponses: maxResponses
        )
        add(responder)
        return responder
    }
}
