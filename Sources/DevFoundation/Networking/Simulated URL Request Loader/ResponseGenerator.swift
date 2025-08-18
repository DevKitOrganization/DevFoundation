//
//  File.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import Foundation


extension SimulatedURLRequestLoader {
    public protocol ResponseGenerator: AnyObject, Sendable {
        func response(for requestComponents: RequestComponents) async -> Response?
    }
}
