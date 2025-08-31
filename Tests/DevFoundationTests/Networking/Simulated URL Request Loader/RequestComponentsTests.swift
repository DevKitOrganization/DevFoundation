//
//  RequestComponentsTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct RequestComponentsTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSucceedsWithValidRequest() throws {
        var urlRequest = randomURLRequest()
        urlRequest.httpHeaderItems = Array(count: randomInt(in: 3 ... 5)) { randomHTTPHeaderItem() }

        let requestComponents = try #require(SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest))
        let expectedURLComponents = URLComponents(url: urlRequest.url!.absoluteURL, resolvingAgainstBaseURL: false)!

        #expect(requestComponents.url == urlRequest.url?.absoluteURL)
        #expect(requestComponents.httpMethod == HTTPMethod(rawValue: urlRequest.httpMethod!))
        #expect(requestComponents.headerItems == Set(urlRequest.httpHeaderItems))
        #expect(requestComponents.urlRequest == urlRequest)
        #expect(requestComponents.body == urlRequest.httpBody)
        #expect(requestComponents.urlComponents == expectedURLComponents)
    }


    @Test
    mutating func initFailsWithNilURL() {
        var urlRequest = randomURLRequest()
        urlRequest.url = nil

        let requestComponents = SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest)

        #expect(requestComponents == nil)
    }


    @Test
    mutating func bodyReturnsEmptyDataWhenHTTPBodyIsNil() throws {
        var urlRequest = randomURLRequest()
        urlRequest.httpBody = nil

        let requestComponents = try #require(SimulatedURLRequestLoader.RequestComponents(urlRequest: urlRequest))

        #expect(requestComponents.body == Data())
    }
}
