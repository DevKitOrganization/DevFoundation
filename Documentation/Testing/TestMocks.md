---
description: Test mock conventions: Stub and ThrowingStub, argument structures, prologues, naming
read-when: Creating a new mock, or controlling when a mock runs in an async test
---

# Test Mocks

How mocks are built in DevFoundation.
Read [Dependency Injection](../DependencyInjection.md) first; it covers what gets injected and
therefore what gets mocked.


## Overview

Mocks use DevTesting’s `Stub` and `ThrowingStub` types, which record calls and return configured
values. Every mock follows the same patterns, so tests read the same way. These patterns need
DevTesting 1.7 or later.


## When to Mock

Create a mock when a type

  - has **non-deterministic behavior,** like the network, file I/O, time, or system services;
  - needs to be **controlled or observed** in a test; or
  - **behaves differently across environments,** like a platform API that differs between macOS
    and iOS.

Use the real type when its behavior is **deterministic,** when the real implementation gives
**enough coverage,** or when an abstraction would add **complexity without a testing benefit.**
These are used directly:

  - **Value types** and their operations
  - **`NotificationCenter`, `UserDefaults`, and `Bundle`**


## Core Patterns

### 1. Stubs

Mocks conform to the **protocol,** not the concrete type. Each function or property calls a stub:

    import DevTesting


    final class MockDataLoader: DataLoading {
        nonisolated(unsafe) var baseURLStub = Stub<Void, URL>()
        nonisolated(unsafe) var loadStub = ThrowingStub<URLRequest, Data, any Error>()


        var baseURL: URL {
            baseURLStub()
        }


        func load(_ request: URLRequest) throws -> Data {
            try loadStub(request)
        }
    }

  - Stub properties are `nonisolated(unsafe)` for Swift 6 concurrency.
  - Function implementations only call their stubs.
  - Stubs are **default-initialized** wherever possible, as described below.

### 2. Default-Initialized Stubs

An unconfigured, force-unwrapped stub crashes the test process. Under Swift Testing’s parallel
execution, that crash is hard to trace to a test, and it ends the whole run. So stubs start with a
placeholder instead, using DevTesting’s `DefaultStubValueProviding`:

  - **`Stub()`** returns the return type’s `defaultStubValue` until configured. DevTesting conforms
    common standard library and Foundation types, using recognizable placeholders where possible,
    such as `1_234_567_890` and `"default stub"`. Stubs that return `Void` also have an `init()`.
  - **`ThrowingStub()`,** for stubs that throw `any Error`, throws an unspecified error until
    configured.

A default only keeps an unconfigured stub from crashing. It isn’t realistic data or a behavior
contract, so tests still configure every stub whose value they depend on. Because a default
throwing stub throws, a test of a success path must configure it. Never make a failing test pass
by changing a mock’s default; configure the stub in the test.

Conform DevFoundation’s own types to `DefaultStubValueProviding` in the test target, composing their
properties’ defaults:

    extension Version: DefaultStubValueProviding {
        static var defaultStubValue: Version {
            return Version(name: .defaultStubValue, revision: .defaultStubValue)
        }
    }

Force-unwrap a stub only when no default is possible, such as a return type that can’t be
conformed or a stub that throws a specific error type. Tests must configure those stubs before
they’re called.

### 3. Argument Structures

When a function has more than one parameter, the stub takes a nested argument structure:

    final class MockItemStore: ItemStoring {
        struct SaveArguments {
            let item: Item
            let collectionID: Collection.ID
        }


        nonisolated(unsafe) var saveStub = ThrowingStub<SaveArguments, Void, any Error>()


        func save(_ item: Item, in collectionID: Collection.ID) async throws {
            try saveStub(.init(item: item, collectionID: collectionID))
        }
    }

### 4. Delegate Mocks

Delegate protocols get a `Mock*Delegate` with one stub per function, like any other mock. Never
hand-roll a spy with counters; that loses argument verification.

### 5. Errors

When a test just needs an error, use DevTesting’s `ArbitraryError`. `randomError()` creates one
whose description begins with the calling file and function:

    let error = randomError()
    mockLoader.loadStub = ThrowingStub(defaultError: error)

    #expect(throws: error) {
        try client.fetchItem(withID: itemID)
    }

Don’t declare local error types for individual tests. When a test needs a specific error, such as
one the code under test handles differently, use that error.


## Execution Control

Some async tests need to control when a mock runs. Mock functions can have optional prologue and
epilogue closures:

| Goal | Use |
|---|---|
| Hold the mock open to inspect intermediate state | Prologue |
| Gate the stub until the test signals | Prologue |
| Wait until a fire-and-forget caller reaches the mock | Epilogue |
| Confirm the mock was called before checking side effects | Epilogue |

### Prologues

A prologue runs **before** the stub and is awaited inline, so it can suspend the mock:

    final class MockDataLoader: DataLoading {
        nonisolated(unsafe) var loadPrologue: (() async throws -> Void)?
        nonisolated(unsafe) var loadStub = ThrowingStub<URLRequest, Data, any Error>()


        func load(_ request: URLRequest) async throws -> Data {
            try await loadPrologue?()
            return try loadStub(request)
        }
    }

### Epilogues

An epilogue runs **after** the stub returns, in a `Task` launched from a `defer` block, so it
doesn’t delay the caller:

    func itemDidChange(_ item: Item) {
        defer {
            if let epilogue = itemDidChangeEpilogue {
                Task {
                    try? await epilogue()
                }
            }
        }

        itemDidChangeStub(item)
    }

**Common mistake:** using an epilogue to block. The mock has already returned when the epilogue
runs, so awaiting inside it doesn’t keep the caller suspended. Use a prologue to hold a mock open.

See [Async Test Patterns](AsyncTestPatterns.md) for how tests use these.


## Organization and Naming

  - **One mock per file,** named `Mock[ProtocolName].swift`, containing `Mock[ProtocolName]`.
  - **Argument structures** are named `[FunctionName]Arguments`.
  - **Stub properties** are named `[functionName]Stub`, with `[functionName]Prologue` and
    `[functionName]Epilogue` where needed.
  - **Mocks live in the test target’s `Testing Helpers/` folder.** When a second test target needs
    the same mocks, they move to a shared `*Testing` library target.


## Thread Safety

`nonisolated(unsafe)` assumes that tests configure stubs during setup, before any concurrent
access, and that mocks don’t need further synchronization. Add synchronization if a mock is used
concurrently in ways that break those assumptions.
