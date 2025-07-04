//
//  MockHTTPClientResponseInterceptor.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import DevFoundation
import DevTesting
import Foundation

final class MockHTTPClientResponseInterceptor: HashableByID, HTTPClientResponseInterceptor {
    struct InterceptArguments {
        let response: HTTPResponse<Data>
        let client: HTTPClient
        let request: URLRequest
    }


    nonisolated(unsafe) var interceptPrologue: (() async throws -> Void)?
    nonisolated(unsafe) var interceptStub: ThrowingStub<InterceptArguments, HTTPResponse<Data>?, any Error>!


    func intercept(
        _ response: HTTPResponse<Data>,
        from client: HTTPClient,
        for request: URLRequest
    ) async throws -> HTTPResponse<Data>? {
        try await interceptPrologue?()
        return try interceptStub(.init(response: response, client: client, request: request))
    }
}
