//
//  HTTPResponse.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/15/25.
//

import Foundation


/// An HTTP response, which pairs an `HTTPURLResponse` with a type-safe representation of the response’s body.
public struct HTTPResponse<Body> {
    /// The response’s HTTP URL response.
    public let httpURLResponse: HTTPURLResponse

    /// The response’s body.
    public var body: Body

    
    /// Creates a new HTTP response with the specified HTTP URL response and body.
    /// - Parameters:
    ///   - httpURLResponse: The response’s HTTP URL response.
    ///   - body: The response’s body.
    public init(httpURLResponse: HTTPURLResponse, body: Body) {
        self.httpURLResponse = httpURLResponse
        self.body = body
    }


    /// The status code of the response.
    public var statusCode: HTTPStatusCode {
        return httpURLResponse.httpStatusCode
    }

    
    /// Returns a copy of the response whose body is the result of calling a closure.
    ///
    /// - Parameter transform: A closure to transform the response’s body.
    public func mapBody<MappedBody, ErrorType>(
        _ transform: (Body) throws(ErrorType) -> MappedBody
    ) throws(ErrorType) -> HTTPResponse<MappedBody> {
        return HTTPResponse<MappedBody>(
            httpURLResponse: httpURLResponse,
            body: try transform(body)
        )
    }
}


extension HTTPResponse: Equatable where Body: Equatable { }
extension HTTPResponse: Hashable where Body: Hashable { }
extension HTTPResponse: Sendable where Body: Sendable { }


// MARK: - Status Codes

extension HTTPResponse {
    /// Throws an error if the response’s status code satisfies some criteria.
    ///
    /// This function is named so that it reads well when using ``HTTPStatusCode``’s range-related boolean properties.
    /// For example, to throw if a status code indicates an error, you can write:
    ///
    ///     try httpResponse.throwIfStatusCode(\.isError)
    /// 
    /// The function returns `self` if it doesn’t throw, which allows you to chain it with calls to ``mapBody(_:)``.
    ///
    /// - Parameter shouldThrow: A predicate that returns whether the function should throw.
    /// - Returns: `self` if no error is thrown.
    /// - Throws: Throws an ``InvalidHTTPStatusCodeError`` if `shouldThrow` returns `true` when given the response’s
    ///   status code.
    public func throwIfStatusCode(_ shouldThrow: (HTTPStatusCode) -> Bool) throws -> Self {
        guard shouldThrow(statusCode) else {
            return self
        }

        throw InvalidHTTPStatusCodeError(httpURLResponse: httpURLResponse)
    }


    /// Throws an error unless the response’s status code satisfies some criteria.
    ///
    /// This function is named so that it reads well when using ``HTTPStatusCode``’s range-related boolean properties.
    /// For example, to throw unless a status code indicate success, you can write:
    ///
    ///     try httpResponse.throwUnlessStatusCode(\.isSuccess)
    ///
    /// The function returns `self` if it doesn’t throw, which allows you to chain it with calls to ``mapBody(_:)``.
    ///
    /// - Parameter shouldNotThrow: A predicate that returns whether the function should _not_ throw.
    /// - Returns: `self` if no error is thrown.
    /// - Throws: Throws an ``InvalidHTTPStatusCodeError`` if `shouldNotThrow` returns `false` when given the response’s
    ///   status code.
    public func throwUnlessStatusCode(_ shouldNotThrow: (HTTPStatusCode) -> Bool) throws -> Self {
        return try throwIfStatusCode { !shouldNotThrow($0) }
    }
}


// MARK: - Decoding

extension HTTPResponse where Body == Data {
    /// Returns a copy of the response whose body has been decoded into the specified type.
    ///
    /// - Parameters:
    ///   - type: The type to decode the body as.
    ///   - decoder: The decoder with which to decode the body.
    /// - Throws: Throws any errors that occur during decoding.
    public func decode<Value>(
        _ type: Value.Type,
        decoder: some TopLevelDecoder<Data>
    ) throws -> HTTPResponse<Value>
    where Value: Decodable {
        return try mapBody { (body) in
            try decoder.decode(Value.self, from: body)
        }
    }


    /// Returns a copy of the response whose body has been decoded into the specified type starting at a given top-level
    /// key.
    ///
    /// - Parameters:
    ///   - type: The type to decode the body as.
    ///   - decoder: The decoder with which to decode the body.
    ///   - topLevelKey: The top-level key at which to start decoding.
    /// - Throws: Throws any errors that occur during decoding.
    public func decode<Value, Key>(
        _ type: Value.Type,
        decoder: some TopLevelDecoder<Data>,
        topLevelKey: Key
    ) throws -> HTTPResponse<Value>
    where Value: Decodable, Key: CodingKey {
        return try mapBody { (body) in
            try decoder.decode(Value.self, from: body, topLevelKey: topLevelKey)
        }
    }
}
