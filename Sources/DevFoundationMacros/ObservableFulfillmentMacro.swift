//
//  ObservableFulfillmentMacro.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/12/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ObservableFulfillmentMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let (conditionExpr, bodyExpr) = try extractClosures(from: node)

        // Generate non-throwing code
        return """
            {
                let observations = Observations(\(conditionExpr))

                let observationTask = Task.immediate {
                    for await value in observations where value {
                        break
                    }
                }

                async let value = \(bodyExpr)()
                _ = await observationTask.value
                return await value
            }()
            """
    }
}


public struct ThrowingObservableFulfillmentMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let (conditionExpr, bodyExpr) = try extractClosures(from: node)

        // Generate throwing code
        return """
            {
                let observations = Observations(\(conditionExpr))

                let observationTask = Task.immediate {
                    for try await value in observations where value {
                        break
                    }
                }

                async let value = try \(bodyExpr)()
                _ = try await observationTask.value
                return try await value
            }()
            """
    }
}


// MARK: - Helper Functions

private func extractClosures(
    from node: some FreestandingMacroExpansionSyntax
) throws -> (condition: ClosureExprSyntax, body: ClosureExprSyntax) {
    let arguments = node.arguments
    let trailingClosure = node.trailingClosure
    let additionalTrailingClosures = node.additionalTrailingClosures

    if arguments.count == 2 && trailingClosure == nil {
        // Case 1: Both arguments in arguments list (no trailing closures)
        // #observableFulfillment(of: { ... }, whileExecuting: { ... })
        guard
            let conditionExpr = arguments.first?.expression.as(ClosureExprSyntax.self),
            let bodyExpr = arguments.dropFirst().first?.expression.as(ClosureExprSyntax.self)
        else {
            throw MacroError.invalidConditionArgument
        }
        return (conditionExpr, bodyExpr)
    } else if arguments.count == 1, let trailing = trailingClosure, additionalTrailingClosures.isEmpty {
        // Case 2: One argument + trailing closure
        // #observableFulfillment(of: { ... }) { ... }
        guard let conditionExpr = arguments.first?.expression.as(ClosureExprSyntax.self) else {
            throw MacroError.invalidConditionArgument
        }
        return (conditionExpr, trailing)
    } else if arguments.isEmpty,
        let trailing = trailingClosure,
        additionalTrailingClosures.count == 1,
        let additionalClosure = additionalTrailingClosures.first?.closure
    {
        // Case 3: Trailing closure + additional trailing closure
        // #observableFulfillment { ... } whileExecuting: { ... }
        return (trailing, additionalClosure)
    }

    throw MacroError.invalidArgumentCount
}


enum MacroError: Error, CustomStringConvertible {
    case invalidArgumentCount
    case invalidConditionArgument
    case invalidBodyArgument

    var description: String {
        switch self {
        case .invalidArgumentCount:
            return "#observableFulfillment requires exactly 2 closure arguments"
        case .invalidConditionArgument:
            return "First argument must be a closure"
        case .invalidBodyArgument:
            return "Second argument must be a closure"
        }
    }
}
