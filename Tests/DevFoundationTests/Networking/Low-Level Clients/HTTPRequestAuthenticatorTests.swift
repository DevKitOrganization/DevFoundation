//
//  HTTPRequestAuthenticatorTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing


struct HTTPRequestAuthenticatorTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func throwIfResponseIndicatesAuthenticationFailureDoesNothingWhenStatusCodeIsNotUnauthorized() {
        let authenticator = DefaultHTTPRequestAuthenticator()

        let urlRequest = randomURLRequest()
        for statusCode in [100 ..< 401, 402 ..< 600].joined() {
            let response = HTTPResponse(
                httpURLResponse: randomHTTPURLResponse(statusCode: statusCode),
                body: Data()
            )

            do {
                try authenticator.throwIfResponseIndicatesAuthenticationFailure(
                    response: response,
                    request: urlRequest,
                    context: ()
                )
            } catch {
                Issue.record("throws unexpected error: \(error)")
            }
        }
    }


    @Test
    mutating func throwIfResponseIndicatesAuthenticationFailureThrowsWhenStatusCodeIsUnauthorized() {
        let authenticator = DefaultHTTPRequestAuthenticator()
        let response = HTTPResponse(
            httpURLResponse: randomHTTPURLResponse(statusCode: 401),
            body: Data()
        )

        #expect(throws: UnauthorizedHTTPRequestError.self) {
            try authenticator.throwIfResponseIndicatesAuthenticationFailure(
                response: response,
                request: randomURLRequest(),
                context: ()
            )
        }
    }
}


private struct DefaultHTTPRequestAuthenticator: HTTPRequestAuthenticator {
    func prepare(
        _ request: URLRequest,
        context: Void,
        previousFailures: [HTTPRequestAuthenticationFailure]
    ) async throws -> URLRequest? {
        fatalError("not implemented")
    }
}
