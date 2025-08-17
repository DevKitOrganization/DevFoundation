//
//  MockWebServiceRequest.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/18/25.
//

import DevFoundation
import DevTesting
import Foundation

final class MockWebServiceRequest: WebServiceRequest {
    typealias Context = String
    typealias BaseURLConfiguration = MockBaseURLConfiguration

    nonisolated(unsafe) var httpMethod: HTTPMethod
    nonisolated(unsafe) var headerItems: [HTTPHeaderItem]
    nonisolated(unsafe) var context: Context
    nonisolated(unsafe) var baseURL: Int
    nonisolated(unsafe) var pathComponents: [URLPathComponent]
    nonisolated(unsafe) var fragment: String?
    nonisolated(unsafe) var queryItems: [URLQueryItem]
    nonisolated(unsafe) var automaticallyPercentEncodesQueryItems: Bool
    nonisolated(unsafe) var httpBodyResult: Result<HTTPBody?, any Error>
    nonisolated(unsafe) var mapResponseStub: ThrowingStub<HTTPResponse<Data>, String, any Error>!


    init(
        httpMethod: HTTPMethod,
        headerItems: [HTTPHeaderItem],
        context: Context,
        baseURL: Int,
        pathComponents: [URLPathComponent],
        fragment: String?,
        queryItems: [URLQueryItem],
        automaticallyPercentEncodesQueryItems: Bool = true,
        httpBodyResult: Result<HTTPBody?, any Error>
    ) {
        self.httpMethod = httpMethod
        self.headerItems = headerItems
        self.context = context
        self.baseURL = baseURL
        self.pathComponents = pathComponents
        self.fragment = fragment
        self.queryItems = queryItems
        self.automaticallyPercentEncodesQueryItems = automaticallyPercentEncodesQueryItems
        self.httpBodyResult = httpBodyResult
    }


    var httpBody: HTTPBody? {
        get throws {
            return try httpBodyResult.get()
        }
    }


    func mapResponse(_ response: HTTPResponse<Data>) throws -> String {
        return try mapResponseStub(response)
    }
}
