//
//  JSONBodyWebServiceRequestTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/18/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct JSONBodyWebServiceRequestTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func jsonEncoderReturnsUncustomizedJSONEncoder() throws {
        let jsonBody = MockJSONBody(dataProperty: randomData(), dateProperty: randomDate())
        let request = DefaultJSONBodyWebServiceRequest(jsonBody: jsonBody)
        let jsonEncoder = request.jsonEncoder

        // Do some basic tests that this is an uncustomized JSON encoder
        #expect(jsonEncoder.outputFormatting == [])
        #expect(jsonEncoder.userInfo.isEmpty)

        // Encode jsonBody with an uncustomized JSON encoder and the request’s, decode the resultant data, and make
        // sure the decoded MockJSONBody instances are the same
        let requestData = try jsonEncoder.encode(jsonBody)
        let uncustomizedData = try JSONEncoder().encode(jsonBody)

        let requestBody = try JSONDecoder().decode(MockJSONBody.self, from: requestData)
        let uncustomizedBody = try JSONDecoder().decode(MockJSONBody.self, from: uncustomizedData)
        #expect(requestBody == uncustomizedBody)
    }


    @Test
    mutating func httpBodyEncodesJSONBody() throws {
        let jsonBody = MockJSONBody(dataProperty: randomData(), dateProperty: randomDate())

        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        jsonEncoder.dataEncodingStrategy = .deferredToData
        jsonEncoder.dateEncodingStrategy = .millisecondsSince1970

        let request = MockJSONBodyWebServiceRequest(jsonBody: jsonBody, jsonEncoder: jsonEncoder)
        let httpBody = try #require(try request.httpBody)

        #expect(httpBody.contentType == .json)
        let expectedData = try jsonEncoder.encode(jsonBody)
        #expect(httpBody.data == expectedData)
    }


    @Test
    mutating func httpBodyThrowsWhenEncodingThrows() {
        let expectedError = randomError()
        let request = MockJSONBodyWebServiceRequest(
            jsonBody: AlwaysThrowingEncodable(error: expectedError),
            jsonEncoder: JSONEncoder()
        )

        #expect(throws: expectedError) {
            try request.httpBody
        }
    }
}


// MARK: - Supporting Types

private struct MockJSONBody: Codable, Hashable {
    // These properties are chosen to exercise JSONEncoder specific configuration. They’re multi-word to exercise
    // the key encoding strategy, and they’re data and date to exercise the data- and date-encoding strategies.
    var dataProperty: Data
    var dateProperty: Date
}


private struct DefaultJSONBodyWebServiceRequest: JSONBodyWebServiceRequest {
    typealias Context = String
    typealias BaseURLConfiguration = SingleBaseURLConfiguration

    var jsonBody: MockJSONBody


    var httpMethod: HTTPMethod {
        fatalError("not implemented")
    }


    var context: Context {
        fatalError("not implemented")
    }


    var pathComponents: [URLPathComponent] {
        fatalError("not implemented")
    }


    func mapResponse(_ response: HTTPResponse<Data>) throws {
        fatalError("not implemented")
    }
}


private struct MockJSONBodyWebServiceRequest<JSONBody>: JSONBodyWebServiceRequest
where JSONBody: Encodable & Sendable {
    typealias Context = String
    typealias BaseURLConfiguration = SingleBaseURLConfiguration

    var jsonBody: JSONBody
    var jsonEncoder: JSONEncoder


    var httpMethod: HTTPMethod {
        fatalError("not implemented")
    }


    var context: Context {
        fatalError("not implemented")
    }


    var pathComponents: [URLPathComponent] {
        fatalError("not implemented")
    }


    func mapResponse(_ response: HTTPResponse<Data>) throws {
        fatalError("not implemented")
    }
}
