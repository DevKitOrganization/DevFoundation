//
//  DevFoundationMacrosPlugin.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/12/25.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct DevFoundationMacrosPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        ObservableFulfillmentMacro.self,
        ThrowingObservableFulfillmentMacro.self,
    ]
}
