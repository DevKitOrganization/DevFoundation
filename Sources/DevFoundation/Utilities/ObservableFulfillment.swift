//
//  ObservableFulfillment.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/12/25.
//

import Foundation

/// Executes a closure while observing a condition, ensuring the condition becomes true.
///
/// This macro expands to inline code that creates an `Observations` instance in the caller's context,
/// ensuring proper actor isolation and avoiding timing issues with observation setup.
///
/// - Parameters:
///   - condition: A closure that returns a Boolean value to observe.
///   - body: A closure that performs the work.
///
/// ## Example
///
///     await #observableFulfillment {
///         state.isReady
///     } whileExecuting: {
///         state.performWork()
///     }
@freestanding(expression)
public macro observableFulfillment<ReturnType>(
    of condition: @Sendable () -> Bool,
    whileExecuting body: @Sendable () async -> ReturnType
) -> ReturnType = #externalMacro(module: "DevFoundationMacros", type: "ObservableFulfillmentMacro")


/// Executes a throwing closure while observing a condition, ensuring the condition becomes true.
///
/// This macro expands to inline code that creates an `Observations` instance in the caller's context,
/// ensuring proper actor isolation and avoiding timing issues with observation setup.
///
/// - Parameters:
///   - condition: A closure that returns a Boolean value to observe.
///   - body: A closure that performs the work.
///
/// ## Example
///
///     try await #observableFulfillment {
///         try state.isReady
///     } whileExecuting: {
///         try await state.performWork()
///     }
@freestanding(expression)
public macro observableFulfillment<ReturnType>(
    of condition: @Sendable () throws -> Bool,
    whileExecuting body: @Sendable () async throws -> ReturnType
) -> ReturnType = #externalMacro(module: "DevFoundationMacros", type: "ThrowingObservableFulfillmentMacro")
