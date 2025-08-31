//
//  RandomValueGenerating+DevFoundation.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/13/25.
//

import DevFoundation
import DevTesting
import Foundation

extension RandomValueGenerating {
    mutating func randomDate() -> Date {
        return Date(timeIntervalSinceNow: random(TimeInterval.self, in: -10_000 ... 10_000))
    }


    mutating func randomDuration() -> Duration {
        return Duration(
            secondsComponent: random(Int64.self, in: 0 ... 10_000_000),
            attosecondsComponent: random(Int64.self, in: 0 ... 999_999_999_999_999_999)
        )
    }

    mutating func randomError() -> MockError {
        return MockError(id: randomInt(in: 0 ... .max))
    }


    mutating func randomHTTPBody() -> HTTPBody {
        return HTTPBody(contentType: randomMediaType(), data: randomData())
    }


    mutating func randomHTTPHeaderField() -> HTTPHeaderField {
        return HTTPHeaderField(randomAlphanumericString())
    }


    mutating func randomHTTPHeaderItem() -> HTTPHeaderItem {
        return HTTPHeaderItem(
            field: randomHTTPHeaderField(),
            value: randomAlphanumericString()
        )
    }


    mutating func randomHTTPMethod() -> HTTPMethod {
        return randomElement(in: [HTTPMethod.delete, .get, .patch, .post, .put])!
    }


    mutating func randomHTTPStatusCode() -> HTTPStatusCode {
        return HTTPStatusCode(rawValue: randomInt(in: 100 ..< 600))
    }


    mutating func randomHTTPResponse() -> HTTPResponse<Data> {
        return HTTPResponse(httpURLResponse: randomHTTPURLResponse(), body: randomData())
    }


    mutating func randomHTTPURLResponse(statusCode: Int? = nil) -> HTTPURLResponse {
        return HTTPURLResponse(
            url: randomURL(),
            statusCode: statusCode ?? randomInt(in: 100 ..< 600),
            httpVersion: "1.1",
            headerFields: Dictionary(count: randomInt(in: 3 ..< 10)) {
                (randomAlphanumericString(), randomAlphanumericString())
            }
        )!
    }


    mutating func randomMediaType() -> MediaType {
        return MediaType("\(randomAlphanumericString())/\(randomAlphanumericString())")
    }


    mutating func randomURLPathComponent() -> URLPathComponent {
        return URLPathComponent(randomAlphanumericString())
    }


    mutating func randomURLRequest() -> URLRequest {
        var request = URLRequest(url: randomURL())
        request.httpMethod = randomHTTPMethod().rawValue
        request.httpBody = randomData(count: 8)
        return request
    }
}
