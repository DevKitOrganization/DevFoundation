//
//  IdentifiableBySelf.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 7/26/25.
//

import Foundation

/// A type that conforms to `Identifiable` by returning itself as its ID.
///
/// To conform to `IdentifiableBySelf`, a type must also conform to `Hashable`.
public protocol IdentifiableBySelf: Hashable, Identifiable {}


extension IdentifiableBySelf {
    public var id: Self {
        return self
    }
}
