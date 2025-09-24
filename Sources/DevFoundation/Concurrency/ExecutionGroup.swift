//
//  ExecutionGroup.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/10/25.
//

import Foundation
import Synchronization

/// A dynamic group of tasks that tracks its execution status.
///
/// Execution groups can be used to determine whether a group of related tasks is currently executing. It is ideal for
/// driving whether an indeterminate progress view should be displayed in a UI. In such cases, the asynchronous tasks
/// that affect the display of the progress indicator can all be added to an execution group, and whether the progress
/// view should be displayed can be driven to the execution group’s ``isExecuting`` property.
///
///     @MainActor @Observable final class ContentViewModel {
///         let loadingGroup = ExecutionGroup()
///
///         var isLoading: Bool {
///             loadingGroup.isExecuting
///         }
///
///         …
///
///         func doSomething() {
///             loadingGroup.addTask {
///                 …
///             }
///         }
///
///         func doSomethingElse() {
///             loadingGroup.addTask {
///                 …
///             }
///         }
///     }
///
///
///     struct ContentView: View {
///         var viewModel: ContentViewModel
///
///         var body: some View {
///             Button("Do Something") {
///                 viewModel.doSomething()
///             }
///
///             Button("Do Something Else") {
///                 viewModel.doSomethingElse()
///             }
///
///             if viewModel.isLoading {
///                 ProgressView()
///             }
///         }
///     }
@Observable
public final class ExecutionGroup: Sendable {
    /// The number of tasks that are currently executing.
    private let taskCount = Mutex(0)


    /// Creates a new execution group.
    public init() {
        // Intentionally empty
    }


    /// Whether the group has any currently executing tasks.
    public var isExecuting: Bool {
        access(keyPath: \.isExecuting)
        return taskCount.withLock { $0 != 0 }
    }


    /// Runs the given non-throwing operation asynchronously as part of a new _unstructured_ top-level task in the
    /// execution group.
    ///
    /// - Parameters:
    ///   - priority: The priority of the task. Pass `nil` to use the priority from `Task.currentPriority`.
    ///   - operation: The operation to perform.
    @discardableResult
    public func addTask<Success>(
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable @isolated(any) () async -> Success
    ) -> Task<Success, Never> {
        incrementTaskCount()

        return Task(priority: priority) {
            defer { decrementTaskCount() }
            return await operation()
        }
    }


    /// Runs the given throwing operation asynchronously as part of a new _unstructured_ top-level task in the execution
    /// group.
    ///
    /// - Parameters:
    ///   - priority: The priority of the task. Pass `nil` to use the priority from `Task.currentPriority`.
    ///   - operation: The throwing operation to perform.
    @discardableResult
    public func addTask<Success>(
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable @isolated(any) () async throws -> Success
    ) -> Task<Success, any Error> where Success: Sendable {
        incrementTaskCount()

        return Task(priority: priority) {
            defer { decrementTaskCount() }
            return try await operation()
        }
    }


    /// Increments the group’s task count and mutates its execution state if needed.
    private func incrementTaskCount() {
        withMutation(keyPath: \.isExecuting) {
            taskCount.withLock { $0 += 1 }
        }
    }


    /// Decrements the group’s task count and mutates its execution state if needed.
    private func decrementTaskCount() {
        withMutation(keyPath: \.isExecuting) {
            taskCount.withLock { $0 -= 1 }
        }
    }
}
