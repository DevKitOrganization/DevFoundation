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
/// operation completes before the timeout expires, its result is returned. If the timeout expires first, the operation
/// is canceled.
///
///     let result = try await withTimeout(.seconds(5)) {
///         try await someSlowOperation()
///     }
///
/// - Note: It is up to the operation to check cancellation to honor the timeout. If the operation ignores cancellation,
///   the timeout will not be effective.
///
/// - Parameters:
///   - timeout: The maximum duration to wait for the operation to complete.
///   - priority: The priority of the task that runs the operation. Pass `nil` to use the current task’s priority.
///   - operation: The async operation to perform.
/// - Returns: The result of the operation.
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
            throw TimeoutError()
        }

        // Wait until the main task either finishes or cancels.
        //
        // This loop waits for the next task to complete. If the completed task is the main
        // operation (either by returning or throwing), the value is returned or the error is
        // thrown. If the completed task is the timeout task, the group (and all its children) are
        // canceled, at which point it is the responsibility of the main operation to cooperatively
        // cancel itself (or not).
        repeat {
            do {
                while let next = try await group.next() {
                    group.cancelAll()
                    return next
                }
            } catch is TimeoutError {
                group.cancelAll()
            }
        } while true
    }
}


/// An error indicating that an operation timed out.
private struct TimeoutError: Error {}
