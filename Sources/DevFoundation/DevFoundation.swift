//
//  DevFoundation.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 3/30/25.
//

import Foundation


/// Prepends the specified string with `"com.gauriar.devfoundation."`.
///
/// - Parameter suffix: The string that will have DevFoundation’s reverse DNS prefix prepended to it.
@usableFromInline
func reverseDNSPrefixed(_ suffix: String) -> String {
    return "com.gauriar.devfoundation.\(suffix)"
}
