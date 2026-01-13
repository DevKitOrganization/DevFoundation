//
//  RemoteLocalizationMacrosPlugin.swift
//  RemoteLocalizationMacros
//
//  Created by Prachi Gauriar on 1/13/26.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct RemoteLocalizationMacrosPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        RemoteLocalizedStringMacro.self,
        RemoteLocalizedStringWithFormatMacro.self,
    ]
}
