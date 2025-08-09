//
//  HTTPResponseTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/15/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct HTTPResponseTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsProperties() {
        let httpURLResponse = randomHTTPURLResponse()
        let body = randomData()

        let response = HTTPResponse(httpURLResponse: httpURLResponse, body: body)
        #expect(response.httpURLResponse == httpURLResponse)
        #expect(response.body == body)
        #expect(response.statusCode == httpURLResponse.httpStatusCode)
    }


    @Test
    mutating func mapBodySetsBody() {
        let httpURLResponse = randomHTTPURLResponse()
        let body = randomData()

        let response = HTTPResponse(httpURLResponse: httpURLResponse, body: body)

        let newBody = Array(count: 5) { _ in randomBasicLatinString() }
        let newResponse = response.mapBody { (input) in
            #expect(input == body)
            return newBody
        }

        #expect(newResponse.httpURLResponse == httpURLResponse)
        #expect(newResponse.body == newBody)
    }


    @Test
    mutating func mapBodyThrowsOnError() {
        let body = randomBasicLatinString()
        let response = HTTPResponse(httpURLResponse: randomHTTPURLResponse(), body: body)

        let expectedError = randomError()
        #expect(throws: expectedError) {
            try response.mapBody { (input) throws(MockError) -> String in
                #expect(input == body)
                throw expectedError
            }
        }
    }


    @Test
    mutating func throwIfStatusCodeThrowsWhenShouldThrowReturnsTrue() {
        let response = randomHTTPResponse()
        #expect(throws: InvalidHTTPStatusCodeError(httpURLResponse: response.httpURLResponse)) {
            try response.throwIfStatusCode { _ in true }
        }
    }


    @Test
    mutating func throwIfStatusCodeDoesNotThrowWhenShouldThrowReturnsFalse() throws {
        let response = randomHTTPResponse()
        let mappedResponse = try response.throwIfStatusCode { _ in false }
        #expect(response == mappedResponse)
    }


    @Test
    mutating func throwUnlessStatusCodeThrowsWhenShouldNotThrowReturnsFalse() {
        let response = randomHTTPResponse()
        #expect(throws: InvalidHTTPStatusCodeError(httpURLResponse: response.httpURLResponse)) {
            _ = try response.throwUnlessStatusCode { _ in false }
        }
    }


    @Test
    mutating func decodeThrowsWhenDecodingThrows() throws {
        let response = randomHTTPResponse()

        #expect(throws: DecodingError.self) {
            try response.decode(Int.self, decoder: JSONDecoder())
        }
    }


    @Test
    mutating func decodeMapsBody() throws {
        let mockCodable = MockCodable(
            array: Array(count: 5) { randomFloat64(in: 0 ... 100) },
            bool: randomBool(),
            int: randomInt(in: -100 ... 100),
            string: randomBasicLatinString()
        )

        let response = HTTPResponse(
            httpURLResponse: randomHTTPURLResponse(),
            body: try JSONEncoder().encode(mockCodable)
        )

        let decodedResponse = try response.decode(MockCodable.self, decoder: JSONDecoder())
        #expect(decodedResponse == response.mapBody { _ in mockCodable })
    }


    @Test
    mutating func decodeTopLevelKeyThrowsWhenDecodingThrows() throws {
        let response = randomHTTPResponse()

        #expect(throws: DecodingError.self) {
            try response.decode(String.self, decoder: JSONDecoder(), topLevelKey: MockCodable.CodingKeys.string)
        }
    }


    @Test
    mutating func decodeTopLevelKeyMapsBody() throws {
        let mockCodable = MockCodable(
            array: Array(count: 5) { randomFloat64(in: 0 ... 100) },
            bool: randomBool(),
            int: randomInt(in: -100 ... 100),
            string: randomBasicLatinString()
        )

        let response = HTTPResponse(
            httpURLResponse: randomHTTPURLResponse(),
            body: try JSONEncoder().encode(mockCodable)
        )

        let decodedResponse = try response.decode(
            [Float64].self,
            decoder: JSONDecoder(),
            topLevelKey: MockCodable.CodingKeys.array
        )
        #expect(decodedResponse == response.mapBody { _ in mockCodable.array })
    }
}
