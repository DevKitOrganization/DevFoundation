//
//  UnfulfillableRequestError.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/24/25.
//

import Foundation

extension SimulatedURLRequestLoader {
    public struct UnfulfillableRequestError: Error, Hashable {
        public let request: URLRequest


        public init(request: URLRequest) {
            self.request = request
        }
    }
}
