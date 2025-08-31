//
//  SuccessResponseTemplateTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/31/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct SuccessResponseTemplateTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsProperties() {
        let statusCode = randomHTTPStatusCode()
        let headerItems = Set(count: randomInt(in: 2 ... 4)) { randomHTTPHeaderItem() }
        let body = randomData()

        let template = SimulatedURLRequestLoader.SuccessResponseTemplate(
            statusCode: statusCode,
            headerItems: headerItems,
            body: body
        )

        #expect(template.statusCode == statusCode)
        #expect(template.headerItems == headerItems)
        #expect(template.body == body)
    }


    @Test
    mutating func responseCreatesValidHTTPURLResponse() throws {
        let statusCode = randomHTTPStatusCode()
        let headerItems = Set(count: randomInt(in: 2 ... 4)) { randomHTTPHeaderItem() }
        let body = randomData()

        let template = SimulatedURLRequestLoader.SuccessResponseTemplate(
            statusCode: statusCode,
            headerItems: headerItems,
            body: body
        )

        let requestComponents = try #require(
            SimulatedURLRequestLoader.RequestComponents(urlRequest: randomURLRequest())
        )
        let (responseBody, urlResponse) = template.response(for: requestComponents)

        #expect(responseBody == body)

        let httpResponse = try #require(urlResponse as? HTTPURLResponse)
        #expect(httpResponse.url == requestComponents.url)
        #expect(httpResponse.statusCode == statusCode.rawValue)

        let expectedHeaderFields = Dictionary(
            headerItems.map { ($0.field.rawValue, $0.value) },
            uniquingKeysWith: { $1 }
        )
        #expect(httpResponse.allHeaderFields as? [String: String] == expectedHeaderFields)
    }


    @Test
    mutating func responseHandlesDuplicateHeaderFields() throws {
        let statusCode = randomHTTPStatusCode()
        let repeatedField = randomHTTPHeaderField()
        let value1 = randomAlphanumericString()
        let value2 = randomAlphanumericString()
        let headerItems: Set<HTTPHeaderItem> = [
            HTTPHeaderItem(field: repeatedField, value: value1),
            HTTPHeaderItem(field: repeatedField, value: value2),
            randomHTTPHeaderItem(),
        ]
        let body = randomData()

        let template = SimulatedURLRequestLoader.SuccessResponseTemplate(
            statusCode: statusCode,
            headerItems: headerItems,
            body: body
        )

        let requestComponents = try #require(
            SimulatedURLRequestLoader.RequestComponents(urlRequest: randomURLRequest())
        )
        let (_, urlResponse) = template.response(for: requestComponents)

        let httpResponse = try #require(urlResponse as? HTTPURLResponse)
        let headerValue = httpResponse.allHeaderFields[repeatedField.rawValue] as? String
        #expect([value1, value2].contains(headerValue))
    }
}
