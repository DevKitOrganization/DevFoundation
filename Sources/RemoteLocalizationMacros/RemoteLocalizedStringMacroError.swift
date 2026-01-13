//
//  RemoteLocalizedStringMacroError.swift
//  RemoteLocalizationMacros
//
//  Created by Prachi Gauriar on 1/13/26.
//

import Foundation

enum RemoteLocalizedStringMacroError: Error, CustomStringConvertible {
    case requiresStringLiteral
    case requiresFormatStringLiteral

    var description: String {
        switch self {
        case .requiresStringLiteral:
            return "remoteLocalizedString macro requires a string literal as the first argument"
        case .requiresFormatStringLiteral:
            return "remoteLocalizedString(format:) macro requires a string literal as the format argument"
        }
    }
}
