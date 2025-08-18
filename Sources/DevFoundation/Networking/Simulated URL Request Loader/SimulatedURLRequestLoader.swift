//
//  SimulatedURLRequestLoader.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import Foundation

public final class SimulatedURLRequestLoader: URLRequestLoader {
    public func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        fatalError("not yet implemented")
    }
}
