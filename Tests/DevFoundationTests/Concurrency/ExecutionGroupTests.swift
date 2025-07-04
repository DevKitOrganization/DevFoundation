//
//  ExecutionGroupTests.swift
//  DevFoundation
//
//  Created by Prachi Gauriar on 4/12/25.
//

import DevFoundation
import DevTesting
import Foundation
import Testing

struct ExecutionGroupTests {
    @Test
    func tasksUpdateIsExecuting() async throws {
        let group = ExecutionGroup()
        #expect(!group.isExecuting)

        await confirmation("task is executed", expectedCount: 2) { (didExecute) in
            await confirmation("emits isExecuting observation events", expectedCount: 2) { (didObserve) in
                withObservationTracking {
                    // Is executing should initially be false
                    #expect(!group.isExecuting)
                } onChange: {
                    // It should change to true
                    didObserve()
                    withObservationTracking {
                        #expect(group.isExecuting)
                    } onChange: {
                        // It should change back to false
                        didObserve()
                        #expect(!group.isExecuting)
                    }
                }

                // Start two tasks
                group.addTask {
                    // While the task is running, isExecuting should be true
                    didExecute()
                    #expect(group.isExecuting)
                    try? await Task.sleep(for: .seconds(0.5))

                }

                group.addTask {
                    // While the task is running, isExecuting should be true
                    didExecute()
                    #expect(group.isExecuting)
                    try? await Task.sleep(for: .seconds(0.5))
                }

                // Wait for the tasks to finish
                try? await Task.sleep(for: .seconds(1.1))

                // When the tasks are finished, isExecuting should be false
                #expect(!group.isExecuting)
            }
        }
    }
}
