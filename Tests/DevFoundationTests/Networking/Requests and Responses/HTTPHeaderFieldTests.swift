//
//  HTTPHeaderFieldTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/15/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct HTTPHeaderFieldTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsValue() {
        let rawValue = randomAlphanumericString()
        let headerField = HTTPHeaderField(rawValue)
        #expect(headerField.rawValue == rawValue.lowercased())
    }


    @Test
    func constantValues() {
        #expect(HTTPHeaderField.accept.rawValue == "accept")
        #expect(HTTPHeaderField.acceptLanguage.rawValue == "accept-language")
        #expect(HTTPHeaderField.authorization.rawValue == "authorization")
        #expect(HTTPHeaderField.contentType.rawValue == "content-type")
        #expect(HTTPHeaderField.userAgent.rawValue == "user-agent")
    }


    @Test
    mutating func urlRequestAccessors() {
        var urlRequest = URLRequest(url: randomURL())

        let headerField = randomHTTPHeaderField()
        #expect(urlRequest.httpHeaderValue(for: headerField) == nil)

        let value1 = randomAlphanumericString()
        urlRequest.setHTTPHeaderValue(value1, for: headerField)
        #expect(urlRequest.httpHeaderValue(for: headerField) == value1)

        let value2 = randomAlphanumericString()
        urlRequest.setHTTPHeaderValue(value2, for: headerField)
        #expect(urlRequest.httpHeaderValue(for: headerField) == value2)

        urlRequest.addHTTPHeaderValue(value1, for: headerField)
        #expect(urlRequest.httpHeaderValue(for: headerField) == "\(value2),\(value1)")
    }


    @Test
    mutating func httpURLResponseAccessor() throws {
        let response = randomHTTPURLResponse()

        let headers = try #require(response.allHeaderFields as? [String: String])
        for (field, value) in headers {
            #expect(response.httpHeaderValue(for: HTTPHeaderField(field)) == value)
        }

        #expect(response.httpHeaderValue(for: HTTPHeaderField(randomAlphanumericString(count: 10))) == nil)
    }
}
