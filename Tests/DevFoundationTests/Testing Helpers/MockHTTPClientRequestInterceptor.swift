//
//  MockHTTPClientRequestInterceptor.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import DevFoundation
import DevTesting
import Foundation


final class MockHTTPClientRequestInterceptor: HashableByID, HTTPClientRequestInterceptor {
    struct InterceptArguments {
        let request: URLRequest
        let client: HTTPClient
    }


    nonisolated(unsafe)
    var interceptPrologue: (() async throws -> Void)?

    nonisolated(unsafe)
    var interceptStub: ThrowingStub<InterceptArguments, URLRequest, any Error>!


    func intercept(_ request: URLRequest, from client: HTTPClient) async throws -> URLRequest {
        try await interceptPrologue?()
        return try interceptStub(.init(request: request, client: client))
    }
}
