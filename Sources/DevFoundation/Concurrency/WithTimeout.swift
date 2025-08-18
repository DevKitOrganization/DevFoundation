//
//  WithTimeout.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 8/18/25.
//

import Foundation

/// Runs an async operation with a timeout.
///
/// This function creates a structured concurrency context where the provided operation races against a timeout. If the
/// operation completes before the timeout expires, its result is returned. If the timeout expires first, a
/// ``TimeoutError`` is thrown and the operation is cancelled.
///
///     let result = try await withTimeout(.seconds(5)) {
///         try await someSlowOperation()
///     }
///
/// - Parameters:
///   - timeout: The maximum duration to wait for the operation to complete.
///   - priority: The priority of the task that runs the operation. Pass `nil` to use the current task’s priority.
///   - operation: The async operation to perform.
/// - Returns: The result of the operation if it completes within the timeout.
/// - Throws: ``TimeoutError`` if the timeout expires before the operation completes, or any error thrown by the
///   operation.
public func withTimeout<Success, Failure>(
    _ timeout: Duration,
    priority: TaskPriority? = nil,
    operation: @escaping @Sendable () async throws(Failure) -> Success
) async throws -> Success
where Success: Sendable, Failure: Error {
    let deadline = ContinuousClock.Instant.now + timeout
    return try await withThrowingTaskGroup(of: Success.self) { group in
        // Add the main operation
        group.addTask(priority: priority) {
            return try await operation()
        }

        // Add the timeout task
        group.addTask(priority: .utility) {
            try await Task.sleep(until: deadline)
            throw TimeoutError(timeout: timeout)
        }

        // Return the first result and cancel remaining tasks
        defer {
            group.cancelAll()
        }

        return try await group.next()!
    }
}
