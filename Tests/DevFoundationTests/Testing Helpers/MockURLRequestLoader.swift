//
//  MockURLRequestLoader.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import DevFoundation
import DevTesting
import Foundation


final class MockURLRequestLoader: URLRequestLoader {
    nonisolated(unsafe)
    var dataPrologue: (() async throws -> Void)?

    nonisolated(unsafe)
    var dataStub: ThrowingStub<URLRequest, (Data, URLResponse), any Error>!


    func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        try await dataPrologue?()
        return try dataStub(urlRequest)
    }
}
