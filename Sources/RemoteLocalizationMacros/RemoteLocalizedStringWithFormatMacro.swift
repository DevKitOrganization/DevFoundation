//
//  RemoteLocalizedStringWithFormatMacro.swift
//  RemoteLocalizationMacros
//
//  Created by Prachi Gauriar on 1/13/26.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct RemoteLocalizedStringWithFormatMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard
            let formatArgument = node.arguments.first(where: { $0.label?.text == "format" }),
            let stringLiteral = formatArgument.expression.as(StringLiteralExprSyntax.self),
            stringLiteral.segments.count == 1,
            case .stringSegment(let stringSegment) = stringLiteral.segments.first
        else {
            throw RemoteLocalizedStringMacroError.requiresFormatStringLiteral
        }

        let keyString = stringSegment.content.text

        // Build the arguments for String.localizedStringWithFormat call
        var argumentsArray: [LabeledExprSyntax] = []

        // First argument: the localized string using #localizedString macro
        let bundleArgument = node.arguments.first { $0.label?.text == "bundle" }
        let localizedStringArguments: [LabeledExprSyntax]

        if let bundleArgument = bundleArgument {
            // Use the explicitly provided bundle argument
            localizedStringArguments = [
                LabeledExprSyntax(
                    expression: ExprSyntax(StringLiteralExprSyntax(content: keyString)),
                    trailingComma: .commaToken()
                ),
                LabeledExprSyntax(
                    label: .identifier("bundle"),
                    colon: .colonToken(),
                    expression: bundleArgument.expression
                ),
            ]
        } else {
            // Default to just the key (which will use #bundle by default)
            localizedStringArguments = [
                LabeledExprSyntax(
                    expression: ExprSyntax(StringLiteralExprSyntax(content: keyString))
                )
            ]
        }

        let localizedStringCall = MacroExpansionExprSyntax(
            macroName: .identifier("remoteLocalizedString"),
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax(localizedStringArguments),
            rightParen: .rightParenToken()
        )

        argumentsArray.append(
            LabeledExprSyntax(
                expression: ExprSyntax(localizedStringCall),
                trailingComma: .commaToken()
            )
        )

        // Add remaining arguments (the format parameters) - skip format and bundle arguments
        let formatParameters = node.arguments.filter { argument in
            let label = argument.label?.text
            return label != "format" && label != "bundle"
        }

        for (index, argument) in formatParameters.enumerated() {
            let trailingComma: TokenSyntax? = index == formatParameters.count - 1 ? nil : .commaToken()
            argumentsArray.append(
                LabeledExprSyntax(
                    expression: argument.expression,
                    trailingComma: trailingComma
                )
            )
        }

        let arguments = LabeledExprListSyntax(argumentsArray)

        return ExprSyntax(
            FunctionCallExprSyntax(
                calledExpression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(baseName: .identifier("String")),
                    name: .identifier("localizedStringWithFormat")
                ),
                leftParen: .leftParenToken(),
                arguments: arguments,
                rightParen: .rightParenToken()
            )
        )
    }
}
