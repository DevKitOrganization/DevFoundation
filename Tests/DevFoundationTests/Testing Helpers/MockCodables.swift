//
//  MockCodables.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/19/25.
//

import Foundation


struct MockCodable: Codable, Hashable, Sendable {
    enum CodingKeys: String, CodingKey {
        case array
        case bool
        case int
        case string
    }


    var array: [Float64]
    var bool: Bool
    var int: Int
    var string: String
}


struct AlwaysThrowingEncodable: Encodable {
    let error: any Error


    func encode(to encoder: any Encoder) throws {
        throw error
    }
}
