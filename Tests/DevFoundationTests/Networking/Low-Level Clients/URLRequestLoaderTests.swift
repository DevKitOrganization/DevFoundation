//
//  URLRequestLoaderTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/15/25.
//

#if !os(watchOS)

import DevFoundation
import DevTesting
import Foundation
import Testing
import URLMock


@Suite(.serialized)
struct URLRequestLoaderTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()
    let urlSession: URLSession


    init() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [UMKMockURLProtocol.self]
        self.urlSession = URLSession(configuration: configuration)
    }


    private func enableURLMock() {
        UMKMockURLProtocol.enable()
        UMKMockURLProtocol.setVerificationEnabled(true)
    }


    private func disableURLMock() {
        UMKMockURLProtocol.disable()
        UMKMockURLProtocol.setVerificationEnabled(false)
    }


    @Test
    mutating func dataForRequestSucceedsWithNonNilBody() async throws {
        enableURLMock()
        defer { disableURLMock() }

        let request = randomURLRequest()
        let expectedStatusCode = randomInt(in: 200 ..< 300)
        let expectedBody = randomData()

        let mockRequest = UMKMockHTTPRequest(
            httpMethod: request.httpMethod!,
            url: request.url!,
            checksHeadersWhenMatching: false,
            checksBodyWhenMatching: false
        )

        mockRequest.responder = UMKMockHTTPResponder(statusCode: expectedStatusCode, body: expectedBody)
        UMKMockURLProtocol.expectMockRequest(mockRequest)

        let (actualBody, urlResponse) = try await urlSession.data(for: request)
        #expect(expectedBody == actualBody)

        let httpURLResponse = try #require(urlResponse as? HTTPURLResponse)
        #expect(httpURLResponse.statusCode == expectedStatusCode)

        try UMKMockURLProtocol.verify()
    }


    @Test
    mutating func dataForRequestSucceedsWithNilBody() async throws {
        enableURLMock()
        defer { disableURLMock() }

        let request = randomURLRequest()
        let expectedStatusCode = randomInt(in: 200 ..< 300)

        let mockRequest = UMKMockHTTPRequest(
            httpMethod: request.httpMethod!,
            url: request.url!,
            checksHeadersWhenMatching: false,
            checksBodyWhenMatching: false
        )

        mockRequest.responder = UMKMockHTTPResponder(statusCode: expectedStatusCode, body: nil)
        UMKMockURLProtocol.expectMockRequest(mockRequest)

        let (actualBody, urlResponse) = try await urlSession.data(for: request)
        #expect(actualBody.isEmpty)

        let httpURLResponse = try #require(urlResponse as? HTTPURLResponse)
        #expect(httpURLResponse.statusCode == expectedStatusCode)

        try UMKMockURLProtocol.verify()
    }


    @Test
    mutating func dataForRequestThrowsError() async throws {
        enableURLMock()
        defer { disableURLMock() }

        let request = randomURLRequest()
        let expectedError = randomError()

        let mockRequest = UMKMockHTTPRequest(
            httpMethod: request.httpMethod!,
            url: request.url!,
            checksHeadersWhenMatching: false,
            checksBodyWhenMatching: false
        )
        mockRequest.responder = UMKMockHTTPResponder(error: expectedError)
        UMKMockURLProtocol.expectMockRequest(mockRequest)

        do {
            _ = try await urlSession.data(for: request)
            Issue.record("does not throw error")
        } catch let nsError as NSError {
            // URLProtocol (or URLMock) converts Swift errors into NSErrors, so we need to make sure they’re the same
            // NSError (same domain and code)
            let expectedNSError = expectedError as NSError
            #expect(nsError.domain == expectedNSError.domain)
            #expect(nsError.code == expectedNSError.code)
        }

        try UMKMockURLProtocol.verify()
    }


    private mutating func randomURLRequest() -> URLRequest {
        var urlRequest = URLRequest(url: randomURL(includeQueryItems: false))
        urlRequest.httpMethod = randomElement(in: ["DELETE", "GET", "PATH", "POST", "PUT"])!
        urlRequest.httpBody = randomData()
        return urlRequest
    }
}

#endif
