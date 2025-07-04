//
//  HTTPHeaderItemTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/15/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct HTTPHeaderItemTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsValue() {
        let field = randomHTTPHeaderField()
        let value = randomAlphanumericString()
        let headerItem = HTTPHeaderItem(field: field, value: value)
        #expect(headerItem.field == field)
        #expect(headerItem.value == value)
    }


    @Test
    mutating func urlRequestAccessors() throws {
        var urlRequest = URLRequest(url: randomURL())

        #expect(urlRequest.httpHeaderItems == [])

        // Set a header and make sure the value is what we set
        var headerItem1 = randomHTTPHeaderItem()
        urlRequest.set(headerItem1)
        #expect(urlRequest.httpHeaderItems == [headerItem1])

        // Set a new value for the same field and make sure the value is overwritten
        headerItem1.value = randomAlphanumericString()
        urlRequest.set(headerItem1)
        #expect(urlRequest.httpHeaderItems == [headerItem1])

        // Add a value for the same field and make sure the value is appended
        var headerItem2 = headerItem1
        headerItem2.value = randomAlphanumericString()
        urlRequest.add(headerItem2)
        var expectedHeaderItem = headerItem1
        expectedHeaderItem.value += ",\(headerItem2.value)"
        #expect(urlRequest.httpHeaderItems == [expectedHeaderItem])

        // Overwrite all of them (a few times) and make sure they’re completely overwritten
        for _ in 0 ..< 3 {
            let headerItems = Array(count: 5) { randomHTTPHeaderItem() }
            urlRequest.httpHeaderItems = headerItems
            let actualHeaderItems = urlRequest.httpHeaderItems.sorted { $0.field.rawValue < $1.field.rawValue }
            let expectedHeaderItems = headerItems.sorted { $0.field.rawValue < $1.field.rawValue }
            #expect(actualHeaderItems == expectedHeaderItems)
        }
    }


    @Test
    mutating func httpURLResponseAccessor() throws {
        let response = randomHTTPURLResponse()

        let headers = try #require(response.allHeaderFields as? [String: String])
        let headerItems = response.httpHeaderItems

        #expect(headerItems.count == headers.count)
        for (field, value) in headers {
            #expect(headerItems.contains(.init(field: .init(field), value: value)))
        }
    }
}
