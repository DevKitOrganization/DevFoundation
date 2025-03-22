//
//  HashableByID.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/16/25.
//

import Foundation


/// A type that conforms to `Hashable` using only its ID.
///
/// `HashableByID` provides default conformance to `Hashable` as follows:
///
///   - Two instances are equal if their IDs are the same.
///   - An instance’s hash is computed using only its ID.
public protocol HashableByID: Hashable, Identifiable { }


extension HashableByID {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }


    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
