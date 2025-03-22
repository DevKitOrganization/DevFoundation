//
//  MockHTTPRequestAuthenticator.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import DevFoundation
import DevTesting
import Foundation


final class MockHTTPRequestAuthenticator: HTTPRequestAuthenticator {
    enum Context: CaseIterable, Hashable, Sendable {
        case case1, case2, case3
    }


    struct PrepareArguments {
        let request: URLRequest
        let context: Context
        let previousFailures: [HTTPRequestAuthenticationFailure]
    }


    struct ThrowArguments {
        let response: HTTPResponse<Data>
        let request: URLRequest
        let context: Context
    }


    nonisolated(unsafe)
    var preparePrologue: (() async throws -> Void)?

    nonisolated(unsafe)
    var prepareStub: ThrowingStub<PrepareArguments, URLRequest?, any Error>!

    nonisolated(unsafe)
    var throwPrologue: (() throws -> Void)?

    nonisolated(unsafe)
    var throwStub: ThrowingStub<ThrowArguments, Void, any Error>!


    func prepare(
        _ request: URLRequest,
        context: Context,
        previousFailures: [HTTPRequestAuthenticationFailure]
    ) async throws -> URLRequest? {
        try await preparePrologue?()
        return try prepareStub(.init(request: request, context: context, previousFailures: previousFailures))
    }


    func throwIfResponseIndicatesAuthenticationFailure(
        response: HTTPResponse<Data>,
        request: URLRequest,
        context: Context
    ) throws {
        try throwPrologue?()
        try throwStub(.init(response: response, request: request, context: context))
    }
}
