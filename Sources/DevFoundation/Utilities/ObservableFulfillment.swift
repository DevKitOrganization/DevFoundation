//
//  ObservableFulfillment.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 10/12/25.
//

import Foundation

// MARK: Non-Throwing

/// Executes a closure while observing a condition, ensuring the condition becomes true before returning.
///
/// This function runs the provided body concurrently with an observation of the specified condition. The function waits
/// for both the body to complete and the condition to become true before returning the result. This is useful for
/// scenarios where you need to ensure a certain state is reached while performing an operation.
///
/// The observation mechanism relies on the Swift Observation framework to detect changes to observable properties
/// referenced within the condition. The condition will be evaluated whenever any observed properties change.
///
/// - Parameters:
///   - condition: A closure that returns a Boolean value to observe. The function will wait for this condition to
///     become `true` at least once during execution. The condition should reference observable properties for change
///     detection to work properly.
///   - body: A closure that performs the main work and returns a value of type `ReturnType`.
///
/// - Returns: The value returned by the `body` closure.
///
/// - Note: The observation begins immediately when the function is called. If the condition is already `true` at the
///   start, the observation will complete immediately.
///
/// ## Example
///
///     let result = await observableFulfillment {
///         observableModel.isDataLoaded
///     } whileExecuting: {
///         await observableModel.performDataProcessing()
///     }
///
/// This ensures that `observableModel.isDataLoaded` becomes `true` at some point during the execution of
/// `performDataProcessing()`, and both operations complete before returning the result.
public func observableFulfillment<ReturnType>(
    of condition: @escaping @Sendable () -> Bool,
    whileExecuting body: @Sendable () async -> ReturnType
) async -> ReturnType {
    async let observationCondition = await Observations { condition() }.first { $0 }
    let returnValue = await body()
    _ = await observationCondition
    return returnValue
}


/// Executes a closure while observing a condition, ensuring the condition becomes true before returning.
///
/// This function is a convenience for ``observableFulfillment(of:whileExecuting:)`` which takes an autoclosure instead
/// of a closure.
///
/// - Parameters:
///   - condition: An autoclosure that returns a Boolean value to observe. The function will wait for this condition to
///     become `true` at least once during execution. The condition should reference observable properties for change
///     detection to work properly.
///   - body: A closure that performs the main work and returns a value of type `ReturnType`.
///
/// - Returns: The value returned by the `body` closure.
///
/// ## Example
///
///     let result = await observableFulfillment(of: observableModel.isDataLoaded) {
///         await observableModel.performDataProcessing()
///     }
public func observableFulfillment<ReturnType>(
    of condition: @escaping @autoclosure @Sendable () -> Bool,
    whileExecuting body: @Sendable () async -> ReturnType
) async -> ReturnType {
    return await observableFulfillment(of: condition, whileExecuting: body)
}


// MARK: - Throwing

/// Executes a throwing closure while observing a condition, ensuring the condition becomes true before returning.
///
/// This function runs the provided body concurrently with an observation of the specified condition. The function waits
/// for both the body to complete and the condition to become true before returning the result. This is useful for
/// scenarios where you need to ensure a certain state is reached while performing an operation.
///
/// The observation mechanism relies on the Swift Observation framework to detect changes to observable properties
/// referenced within the condition. The condition will be evaluated whenever any observed properties change.
///
/// - Parameters:
///   - condition: A closure that returns a Boolean value to observe. The function will wait for this condition to
///     become `true` at least once during execution. The condition should reference observable properties for change
///     detection to work properly.
///   - body: A closure that performs the main work and returns a value of type `ReturnType`.
///
/// - Returns: The value returned by the `body` closure.
/// - Throws: Any errors thrown by evaluating `condition` or executing `body`.
///
/// - Note: The observation begins immediately when the function is called. If the condition is already `true` at the
///   start, the observation will complete immediately.
///
/// ## Example
///
///     let result = try await observableFulfillment {
///         observableModel.isDataLoaded
///     } whileExecuting: {
///         try await observableModel.performDataProcessing()
///     }
///
/// This ensures that `isDataLoaded` becomes `true` at some point during the execution of `performDataProcessing()`, and
/// both operations complete before returning the result.
public func observableFulfillment<ReturnType>(
    of condition: @escaping @Sendable () throws -> Bool,
    whileExecuting body: @Sendable () async throws -> ReturnType
) async throws -> ReturnType {
    async let observationCondition = await Observations { try condition() }.first { $0 }
    let returnValue = try await body()
    _ = try await observationCondition
    return returnValue
}


/// Executes a throwing closure while observing a condition, ensuring the condition becomes true before returning.
///
/// This function is a convenience for ``observableFulfillment(of:whileExecuting:)-3g68o`` which takes an autoclosure
/// instead of a closure.
///
/// - Parameters:
///   - condition: An autoclosure that returns a Boolean value to observe. The function will wait for this condition to
///     become `true` at least once during execution. The condition should reference observable properties for change
///     detection to work properly.
///   - body: A closure that performs the main work and returns a value of type `ReturnType`.
///
/// - Returns: The value returned by the `body` closure.
/// - Throws: Any errors thrown by evaluating `condition` or executing `body`.
///
/// ## Example
///
///     let result = try await observableFulfillment(of: observableModel.isDataLoaded) {
///         try await observableModel.performDataProcessing()
///     }
public func observableFulfillment<ReturnType>(
    of condition: @escaping @autoclosure @Sendable () throws -> Bool,
    whileExecuting body: @Sendable () async throws -> ReturnType
) async throws -> ReturnType {
    return try await observableFulfillment(of: condition, whileExecuting: body)
}
