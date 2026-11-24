---
description: Synchronization patterns for testing async and @Observable code without sleeps
read-when: Writing a test that waits on async work, a callback, or @Observable state changes
---

# Async Test Patterns

How to wait on or coordinate async and `@Observable` code in tests. Never use `Task.sleep()` to
wait for work to finish: it makes tests slow and flaky. Use one of the patterns below instead.


## Awaiting Async Functions Directly

The simplest case needs no pattern. Calls to actors and other `async` functions are awaited in the
test like anywhere else:

    // exercise the test by adding the item
    try await store.add(item)

    // expect that the store contains it
    #expect(try await store.item(withID: item.id) == item)

The patterns below are for work that a synchronous call starts in the background.


## Returning Tasks

When a function starts a `Task` and doesn’t need to return anything else, return the task, marked
`@discardableResult` so production callers can ignore it:

    @discardableResult
    func refresh() -> Task<Void, Never> {
        Task {
            await loader.reload()
        }
    }

Tests then await it:

    // exercise the test and wait for it to finish
    await viewModel.refresh().value

Prefer this whenever the signature can change. Use the other patterns when it can’t, such as for a
protocol requirement, or when there’s no task to return.


## Observing `@Observable` State

When an `@Observable` type updates its state from an internal task, wait for the state itself with
`Observations`:

    @MainActor @Test
    mutating func loadingShowsItems() async throws {
        // set up the test by giving the store two items
        let items = [randomItem(), randomItem()]
        mockStore.itemsStub = ThrowingStub(defaultReturnValue: items)

        // exercise the test by creating the view model, which loads in a task
        let viewModel = ItemListViewModel(dependencies: .init(store: mockStore))

        // wait for the load to finish
        _ = await Observations({ viewModel.isLoading }).first { @Sendable in !$0 }

        // expect that the items are shown
        #expect(viewModel.items == items)
    }

`Observations` waits for the real condition, not just for some task to be unblocked. Mark the
closure `@Sendable`, `import Observation`, and make the test `@MainActor`. Write the
`Observations` call inline in each test rather than in a shared helper.

Use `withObservationTracking` only when a test is verifying observation itself, or needs precise
control over when observation starts and stops.


## Confirming Callbacks

`confirmation` checks that a callback, handler, or closure runs:

    await confirmation { handlerCalled in
        let session = Session(onFinish: { _ in
            handlerCalled()
        })

        await session.finish()
    }

The test fails if the confirmation is never called. Call it from a `defer` in handlers with early
returns, so it still happens.


## Synchronous Calls with Asynchronous Effects

When a synchronous call causes asynchronous work that the test can only see through a callback,
pair `confirmation` with an `AsyncStream` signal:

    let (signalStream, signaler) = AsyncStream<Void>.makeStream()
    await confirmation("change reported") { confirm in
        observer.onChange = { change in
            #expect(change.itemID == item.id)
            confirm()
            signaler.yield()
        }

        // exercise the test by renaming the item
        model.rename(item, to: newName)

        // wait for the change to be reported
        await signalStream.first { _ in true }
    }


## Controlling Mocks with Prologues and Epilogues

A prologue holds a mock open so the test can check intermediate state; an epilogue tells the test
that a mock was reached. [Test Mocks](TestMocks.md#execution-control) covers how mocks implement
them.

Blocking on a prologue:

    // set up the test with a loader that waits for a signal
    let (signalStream, signaler) = AsyncStream<Void>.makeStream()
    mockLoader.loadPrologue = {
        await signalStream.first { _ in true }
    }
    mockLoader.loadStub = ThrowingStub(defaultReturnValue: data)

    // exercise the test by starting a refresh
    let task = viewModel.refresh()

    // expect that the view model shows progress while the load is in flight
    #expect(viewModel.isLoading)

    // let the load finish
    signaler.yield()
    await task.value

Awaiting an epilogue:

    // set up the test with an epilogue that signals the call
    let (signalStream, signaler) = AsyncStream<Void>.makeStream()
    mockObserver.itemDidChangeEpilogue = {
        signaler.yield()
    }

    // exercise the test by renaming the item
    model.rename(item, to: newName)

    // wait for the observer to be called
    await signalStream.first { _ in true }

    // expect that the observer saw the change
    #expect(mockObserver.itemDidChangeStub.calls.count == 1)


## Anti-Pattern: `Task.yield()` Loops

Don’t wait for async work with `await Task.yield()` or a `while condition { await Task.yield() }`
loop. A yield gives the scheduler one chance to run something, with no guarantee the awaited work
has progressed. The test races the scheduler, and the race gets worse as more tests run in
parallel.

One exception: when **setup** must wait for a component to register with a mock and there’s no
stub call or epilogue to hook, a bounded poll on a condition the mock can see directly is
acceptable. Polling for a precondition is fine; yielding to wait for the effect under test is not.
