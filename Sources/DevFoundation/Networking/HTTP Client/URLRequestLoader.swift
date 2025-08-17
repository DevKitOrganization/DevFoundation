//
//  URLRequestLoader.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/15/25.
//

import Foundation

public protocol URLRequestLoader: Sendable {
    /// Loads a URL request and delivers its data asynchronously.
    ///
    /// - Parameter urlRequest: The URL request to load.
    /// - Returns: An asynchronously-delivered tuple that contains the URL contents as a `Data` instance, and a
    ///   `URLResponse`.
    func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse)
}


extension URLSession: URLRequestLoader {
    public func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        return try await data(for: urlRequest, delegate: nil)
    }
}
