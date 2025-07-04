//
//  HTTPStatusCodeTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/14/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct HTTPStatusCodeTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsValue() {
        let rawValue = random(Int.self, in: 100 ..< 600)
        #expect(HTTPStatusCode(rawValue).rawValue == rawValue)
    }


    @Test
    mutating func isInformational() {
        for _ in 0 ..< 10 {
            let statusCode = HTTPStatusCode(random(Int.self, in: 100 ..< 200))
            #expect(statusCode.isInformational)
            #expect(!statusCode.isSuccessful)
            #expect(!statusCode.isRedirection)
            #expect(!statusCode.isClientError)
            #expect(!statusCode.isServerError)
            #expect(!statusCode.isError)
        }
    }


    @Test
    mutating func isSuccessful() {
        for _ in 0 ..< 10 {
            let statusCode = HTTPStatusCode(random(Int.self, in: 200 ..< 300))
            #expect(!statusCode.isInformational)
            #expect(statusCode.isSuccessful)
            #expect(!statusCode.isRedirection)
            #expect(!statusCode.isClientError)
            #expect(!statusCode.isServerError)
            #expect(!statusCode.isError)
        }
    }


    @Test
    mutating func isRedirection() {
        for _ in 0 ..< 10 {
            let statusCode = HTTPStatusCode(random(Int.self, in: 300 ..< 400))
            #expect(!statusCode.isInformational)
            #expect(!statusCode.isSuccessful)
            #expect(statusCode.isRedirection)
            #expect(!statusCode.isClientError)
            #expect(!statusCode.isServerError)
            #expect(!statusCode.isError)
        }
    }


    @Test
    mutating func isClientError() {
        for _ in 0 ..< 10 {
            let statusCode = HTTPStatusCode(random(Int.self, in: 400 ..< 500))
            #expect(!statusCode.isInformational)
            #expect(!statusCode.isSuccessful)
            #expect(!statusCode.isRedirection)
            #expect(statusCode.isClientError)
            #expect(!statusCode.isServerError)
            #expect(statusCode.isError)
        }
    }


    @Test
    mutating func isServerError() {
        for _ in 0 ..< 10 {
            let statusCode = HTTPStatusCode(random(Int.self, in: 500 ..< 600))
            #expect(!statusCode.isInformational)
            #expect(!statusCode.isSuccessful)
            #expect(!statusCode.isRedirection)
            #expect(!statusCode.isClientError)
            #expect(statusCode.isServerError)
            #expect(statusCode.isError)
        }
    }


    @Test
    mutating func invalidStatusCode() {
        for _ in 0 ..< 10 {
            let smallStatusCode = HTTPStatusCode(random(Int.self, in: .min ..< 100))
            let largeStatusCode = HTTPStatusCode(random(Int.self, in: 600 ... .max))

            for statusCode in [smallStatusCode, largeStatusCode] {
                #expect(!statusCode.isInformational)
                #expect(!statusCode.isSuccessful)
                #expect(!statusCode.isRedirection)
                #expect(!statusCode.isClientError)
                #expect(!statusCode.isServerError)
                #expect(!statusCode.isError)
            }
        }
    }


    @Test
    mutating func httpURLResponseStatusCode() {
        let statusCode = random(Int.self, in: 100 ..< 600)
        let response = randomHTTPURLResponse(statusCode: statusCode)
        #expect(response.httpStatusCode == HTTPStatusCode(statusCode))
    }
}
