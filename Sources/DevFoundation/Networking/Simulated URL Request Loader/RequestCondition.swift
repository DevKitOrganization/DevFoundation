//
//  RequestCondition.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/17/25.
//

import Foundation
import os.log

extension SimulatedURLRequestLoader {
    public protocol RequestCondition: CustomStringConvertible, Sendable {
        func isFulfilled(by requestComponents: RequestComponents) -> Bool
    }
}


extension SimulatedURLRequestLoader {
    public enum RequestConditions {}
}
