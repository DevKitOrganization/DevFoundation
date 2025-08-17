//
//  MockHTTPClientInterceptor.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import DevFoundation
import DevTesting
import Foundation

final class MockHTTPClientInterceptor<RequestContext>: HTTPClientInterceptor, HashableByID
where RequestContext: Sendable {
    struct InterceptArguments {
        let request: URLRequest
        let context: RequestContext
    }


    nonisolated(unsafe) var interceptStub: ThrowingStub<InterceptArguments, HTTPResponse<Data>, any Error>!
    nonisolated(unsafe) var nextArguments: [InterceptArguments] = []
    nonisolated(unsafe) var interceptPrologue: (@Sendable () async throws -> Void)?


    func intercept(
        request: URLRequest,
        context: RequestContext,
        next: (URLRequest, RequestContext) async throws -> HTTPResponse<Data>
    ) async throws -> HTTPResponse<Data> {
        try await interceptPrologue?()

        let arguments = InterceptArguments(request: request, context: context)
        let nextArguments = self.nextArguments.removeFirst()
        _ = try await next(nextArguments.request, nextArguments.context)
        return try interceptStub(arguments)
    }
}
