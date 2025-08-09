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
        let rawValue = randomInt(in: 100 ..< 600)
        #expect(HTTPStatusCode(rawValue).rawValue == rawValue)
    }


    @Test
    mutating func isInformational() {
        for _ in 0 ..< 10 {
            let statusCode = HTTPStatusCode(randomInt(in: 100 ..< 200))
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
            let statusCode = HTTPStatusCode(randomInt(in: 200 ..< 300))
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
            let statusCode = HTTPStatusCode(randomInt(in: 300 ..< 400))
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
            let statusCode = HTTPStatusCode(randomInt(in: 400 ..< 500))
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
            let statusCode = HTTPStatusCode(randomInt(in: 500 ..< 600))
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
            let smallStatusCode = HTTPStatusCode(randomInt(in: .min ..< 100))
            let largeStatusCode = HTTPStatusCode(randomInt(in: 600 ... .max))

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
        let statusCode = randomInt(in: 100 ..< 600)
        let response = randomHTTPURLResponse(statusCode: statusCode)
        #expect(response.httpStatusCode == HTTPStatusCode(statusCode))
    }
}
