//
//  MediaTypeTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/13/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct MediaTypeTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsRawValueUppercased() {
        let rawValue = "\(randomAlphanumericString())/\(randomAlphanumericString())"

        let httpMethod = MediaType(rawValue)
        #expect(httpMethod.rawValue == rawValue.lowercased())
    }


    @Test
    mutating func uniformTypeIdentifier() {
        #expect(MediaType.json.uniformTypeIdentifier == .json)
        #expect(MediaType.octetStream.uniformTypeIdentifier == .data)
        #expect(MediaType.plainText.uniformTypeIdentifier == .plainText)

        #expect(MediaType("application/xml").uniformTypeIdentifier == .xml)
        #expect(MediaType("image/jpeg").uniformTypeIdentifier == .jpeg)
        #expect(MediaType("image/png").uniformTypeIdentifier == .png)

        let mediaType = randomMediaType()
        #expect(mediaType.uniformTypeIdentifier?.isDynamic == true)
    }


    @Test
    func constantValues() {
        #expect(MediaType.json.rawValue == "application/json")
        #expect(MediaType.octetStream.rawValue == "application/octet-stream")
        #expect(MediaType.plainText.rawValue == "text/plain")
        #expect(MediaType.wwwFormURLEncoded.rawValue == "application/x-www-form-urlencoded")
    }
}
