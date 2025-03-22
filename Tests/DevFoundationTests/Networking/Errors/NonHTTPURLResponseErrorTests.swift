//
//  NonHTTPURLResponseErrorTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import DevTesting
import DevFoundation
import Foundation
import Testing


struct NonHTTPURLResponseErrorTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test
    mutating func initSetsProperties() throws {
        var components = randomURLComponents(includeFragment: false, includeQueryItems: false)
        components.scheme = "ftp"
        let ftpURL = try #require(components.url)

        let urlResponse = URLResponse(
            url: ftpURL,
            mimeType: nil,
            expectedContentLength: random(Int.self, in: 256 ... 1024),
            textEncodingName: nil
        )

        let error = NonHTTPURLResponseError(urlResponse: urlResponse)
        #expect(error.urlResponse == urlResponse)
    }
}
