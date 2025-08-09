//
//  WebServiceRequestTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/18/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct WebServiceRequestTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    func defaultImplementations() throws {
        let request = DefaultWebServiceRequest()
        #expect(request.headerItems.isEmpty)
        #expect(request.fragment == nil)
        #expect(request.queryItems.isEmpty)

        let httpBody = try request.httpBody
        #expect(httpBody == nil)

        #expect(request.automaticallyPercentEncodesQueryItems)
        #expect(request.baseURL as Any is Void)
        #expect(request.authenticatorContext as Any is Void)
    }


    @Test
    mutating func urlRequestCreationWhenQueryItemsIsNonEmpty() throws {
        let httpMethod = randomHTTPMethod()
        let headerItems = Array(count: randomInt(in: 0 ... 5)) { randomHTTPHeaderItem() }
        let baseURL = randomInt(in: .min ... .max)
        let pathComponents = Array(count: randomInt(in: 1 ... 5)) { randomURLPathComponent() }
        let fragment = randomOptional(randomAlphanumericString())
        let queryItems = Array(count: randomInt(in: 1 ... 5)) { randomURLQueryItem() }
        let httpBody = randomHTTPBody()

        let request = MockWebServiceRequest(
            httpMethod: httpMethod,
            headerItems: headerItems,
            authenticatorContext: randomAuthenticatorContext(),
            baseURL: baseURL,
            pathComponents: pathComponents,
            fragment: fragment,
            queryItems: queryItems,
            httpBodyResult: .success(httpBody)
        )

        let baseURLConfiguration = MockBaseURLConfiguration()
        let url = randomURL(includeFragment: false, includeQueryItems: false)
        baseURLConfiguration.urlStub = Stub(defaultReturnValue: url)

        let urlRequest = try request.urlRequest(with: baseURLConfiguration)
        #expect(urlRequest.httpMethod == httpMethod.rawValue)
        #expect(urlRequest.httpBody == httpBody.data)

        let contentTypeHeaderItem = HTTPHeaderItem(field: .contentType, value: httpBody.contentType.rawValue)
        #expect(Set(urlRequest.httpHeaderItems) == Set(headerItems + [contentTypeHeaderItem]))

        var urlComponents = URLComponents(
            url: URL(string: pathComponents.map(\.rawValue).joined(separator: "/"), relativeTo: url)!,
            resolvingAgainstBaseURL: true
        )!
        urlComponents.fragment = fragment
        urlComponents.queryItems = queryItems
        #expect(urlRequest.url == urlComponents.url)
    }


    @Test
    mutating func urlRequestCreationWhenQueryItemsIsEmpty() throws {
        let httpMethod = randomHTTPMethod()
        let headerItems = Array(count: randomInt(in: 0 ... 5)) { randomHTTPHeaderItem() }
        let baseURL = randomInt(in: .min ... .max)
        let fragment = randomOptional(randomAlphanumericString())
        let httpBody = randomHTTPBody()

        let request = MockWebServiceRequest(
            httpMethod: httpMethod,
            headerItems: headerItems,
            authenticatorContext: randomAuthenticatorContext(),
            baseURL: baseURL,
            pathComponents: [],
            fragment: fragment,
            queryItems: [],
            httpBodyResult: .success(httpBody)
        )

        let baseURLConfiguration = MockBaseURLConfiguration()
        let url = randomURL(includeFragment: false, includeQueryItems: false)
        baseURLConfiguration.urlStub = Stub(defaultReturnValue: url)

        let urlRequest = try request.urlRequest(with: baseURLConfiguration)
        #expect(urlRequest.httpMethod == httpMethod.rawValue)
        #expect(urlRequest.httpBody == httpBody.data)

        let contentTypeHeaderItem = HTTPHeaderItem(field: .contentType, value: httpBody.contentType.rawValue)
        #expect(Set(urlRequest.httpHeaderItems) == Set(headerItems + [contentTypeHeaderItem]))

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.fragment = fragment
        #expect(urlRequest.url == urlComponents.url)
    }


    @Test
    mutating func urlRequestCreationWhenQueryItemsIsAlreadyPercentEncoded() throws {
        let httpMethod = randomHTTPMethod()
        let headerItems = Array(count: randomInt(in: 0 ... 5)) { randomHTTPHeaderItem() }
        let baseURL = randomInt(in: .min ... .max)
        let fragment = randomOptional(randomAlphanumericString())
        let queryItems = Array(count: randomInt(in: 1 ... 5)) {
            URLQueryItem(
                name: randomQueryString().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                value: randomQueryString().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            )
        }
        let httpBody = randomHTTPBody()

        let request = MockWebServiceRequest(
            httpMethod: httpMethod,
            headerItems: headerItems,
            authenticatorContext: randomAuthenticatorContext(),
            baseURL: baseURL,
            pathComponents: [],
            fragment: fragment,
            queryItems: queryItems,
            automaticallyPercentEncodesQueryItems: false,
            httpBodyResult: .success(httpBody)
        )

        let baseURLConfiguration = MockBaseURLConfiguration()
        let url = randomURL(includeFragment: false, includeQueryItems: false)
        baseURLConfiguration.urlStub = Stub(defaultReturnValue: url)

        let urlRequest = try request.urlRequest(with: baseURLConfiguration)
        #expect(urlRequest.httpMethod == httpMethod.rawValue)
        #expect(urlRequest.httpBody == httpBody.data)

        let contentTypeHeaderItem = HTTPHeaderItem(field: .contentType, value: httpBody.contentType.rawValue)
        #expect(Set(urlRequest.httpHeaderItems) == Set(headerItems + [contentTypeHeaderItem]))

        var expectedURLComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        expectedURLComponents.fragment = fragment
        expectedURLComponents.percentEncodedQueryItems = queryItems

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.fragment = fragment
        urlComponents.percentEncodedQueryItems = queryItems
        #expect(urlRequest.url == urlComponents.url)
    }


    @Test
    mutating func urlRequestCreationFailsWhenHTTPBodyThrows() throws {
        let expectedError = randomError()

        let request = MockWebServiceRequest(
            httpMethod: randomHTTPMethod(),
            headerItems: [],
            authenticatorContext: randomAuthenticatorContext(),
            baseURL: randomInt(in: .min ... .max),
            pathComponents: [],
            fragment: nil,
            queryItems: [],
            httpBodyResult: .failure(expectedError)
        )

        let baseURLConfiguration = MockBaseURLConfiguration()
        let url = randomURL(includeFragment: false, includeQueryItems: false)
        baseURLConfiguration.urlStub = Stub(defaultReturnValue: url)

        do {
            _ = try request.urlRequest(with: baseURLConfiguration)
            Issue.record("does not throw error")
        } catch let error as InvalidWebServiceRequestError {
            #expect(!error.debugDescription.isEmpty)
            #expect(error.underlyingError as? MockError == expectedError)
        } catch {
            Issue.record("throws unexpected error: \(error)")
        }
    }


    private mutating func randomQueryString() -> String {
        return randomBasicLatinString()
            .replacingOccurrences(of: "&", with: "")
            .replacingOccurrences(of: "=", with: "")
    }
}


// MARK: - Supporting Types

private struct DefaultWebServiceRequest: WebServiceRequest {
    typealias Authenticator = VoidAuthenticator
    typealias BaseURLConfiguration = SingleBaseURLConfiguration


    var httpMethod: HTTPMethod {
        fatalError("not implemented")
    }


    var pathComponents: [URLPathComponent] {
        fatalError("not implemented")
    }


    func mapResponse(_ response: HTTPResponse<Data>) throws {
        // Intentionally empty
    }
}


private struct VoidAuthenticator: HTTPRequestAuthenticator {
    typealias Context = Void


    func prepare(
        _ request: URLRequest,
        context: Void,
        previousFailures: [HTTPRequestAuthenticationFailure]
    ) async throws -> URLRequest? {
        fatalError("not implemented")
    }
}
