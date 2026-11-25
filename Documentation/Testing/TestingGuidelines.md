---
description: Swift Testing conventions, test structure, coverage rules, and DevFoundation specifics
read-when: Writing or reviewing a test, choosing what to run, or deciding what needs a fixture
---

# Testing Guidelines

How to write and maintain tests in DevFoundation.
For how mocks are built, see [Test Mocks](TestMocks.md).
For waiting on async work, see [Async Test Patterns](AsyncTestPatterns.md).


## Running Tests

Run `swift test`, or the AllTests test plan in Xcode, which also reports coverage.
`swift test --filter dfobTests` runs only the `dfob` tests.


## Swift Testing Framework

**IMPORTANT**: This project uses **Swift Testing**, not XCTest. Don’t apply XCTest patterns or
conventions.

  - **Use the `@Test` attribute** instead of function name conventions.
  - **Use `#expect()` and `#require()`** instead of `XCTAssert*()` functions.
  - **Use `#expect(throws:)`** for error conditions.
  - **Organize tests in structs**, not classes.

### Test Naming

  - **No “test” prefixes.** Use descriptive names like `initialLoadingState()`.
  - **Name test types after the concrete type.** For a protocol with a concrete implementation,
    name the tests after the implementation, such as `StandardHTTPClientTests`.

### Test Structure

Unit tests have three parts: set up, exercise, and expect.

  - **Set up**: Create the inputs or mocks needed to exercise the unit under test.
  - **Exercise**: Exercise the unit under test, usually by calling a function with the inputs from
    setup.
  - **Expect**: Expect one or more results, using Swift Testing expressions.

Rules for these sections:

  - Each test has exactly one unit under test. Only its invocation gets an `// exercise` comment.
    Other calls during setup or verification use `// set up` or `// expect` comments.
  - Mark the start of each section with a comment, such as `// set up the test by creating a
    collection with two items` or `// expect that the item order is unchanged`. If two sections
    overlap, mention only the more relevant one.
  - Every test has `// set up` unless there’s genuinely nothing to set up.
  - Every test has `// expect`.
  - `// exercise` is required when a distinct line triggers the behavior under test. Omit it only
    when the action and the assertion are the same expression.
  - Sections can repeat when useful, such as two `// set up` blocks for different dependencies.
  - Comments are prose without colons: `// set up the test by creating a mock loader`, not
    `// set up:` or `// set up: mock loader`.
  - Occasional unstructured comments, like `// unblock and wait for completion`, are fine when
    they help.

### Mock Testing Strategy

  - **Verify calls, not mock implementations.** Test that mocks are called correctly.
  - **Verify arguments,** not just call counts. Extract them with
    `try #require(mock.fooStub.callArguments.first)`, then check their fields:

        @Test
        mutating func saveStoresItemInCollection() async throws {
            // exercise the test by saving the item
            try await library.save(item, in: collectionID)

            // expect that the store was asked to save the item in the collection
            #expect(mockStore.saveStub.calls.count == 1)
            let arguments = try #require(mockStore.saveStub.callArguments.first)
            #expect(arguments.item == item)
            #expect(arguments.collectionID == collectionID)
        }

  - **Use the standard mocks.** Tests share one mock type for each protocol instead of writing
    their own. See [Test Mocks](TestMocks.md).
  - **Always mock injected dependencies,** even when the test doesn’t check them.
  - **Stub minimally.** Only stub functions that matter to the code under test or that the test
    needs to run. Don’t leave comments about omitted stubs.

### Random Values

Tests use DevTesting’s `RandomValueGenerating` for inputs whose exact values don’t matter. Swift
Testing’s test structs are immutable, but `RandomValueGenerating` needs `mutating` functions.
Conform the test struct to `RandomValueGenerating`, add
`var randomNumberGenerator = makeRandomNumberGenerator()`, and mark any test that generates random
values as `mutating`:

    struct ItemTests: RandomValueGenerating {
        var randomNumberGenerator = makeRandomNumberGenerator()


        @Test
        mutating func renamePreservesID() {
            // set up the test by creating an item with a random name
            var item = randomItem()
            let originalID = item.id

            // exercise the test by renaming it
            item.rename(to: randomAlphanumericString())

            // expect that the ID is unchanged
            #expect(item.id == originalID)
        }
    }

Put generators for a module’s own types in `RandomValueGenerating+[ModuleName].swift` in that test
target’s `Testing Helpers/` folder, rather than building values inline in each test.


## File Organization

  - **Test files** are named `[TypeName]Tests.swift`, one per type.
  - **Test folders mirror source folders.** Tests for `Sources/DevFoundation/Networking/` go in
    `Tests/DevFoundationTests/Networking/`.
  - **Shared fixtures and helpers** go in the test target’s `Testing Helpers/` folder.
  - **Group tests by function,** each group preceded by a `// MARK: - [FunctionName]` comment.
  - **Imports**: `@testable import` the module under test; import testing frameworks normally;
    import only what’s needed.


## Coverage

  - **Don’t test pure protocols** that have no implementation.
  - **Every function and getter** has at least one test.
  - **Add tests for edge cases and error conditions,** and test both success and failure for
    throwing functions.

### Throwing Tests

A test that uses `#expect(throws:)` must be marked `throws`, or the compiler reports “Errors
thrown from here are not handled.”

    @Test
    func decodingRejectsUnknownKind() throws {
        #expect(throws: DecodingError.self) {
            try decoder.decode(Kind.self, from: data)
        }
    }

### Boolean Expectations

Don’t compare Booleans to `true` or `false`. Use the value directly or negate it. Optional
Booleans are the exception, because the comparison unwraps them.

    // ✅ Good
    #expect(item.isEnabled)
    #expect(!item.isEnabled)
    #expect(response.isCached == true)  // isCached is Bool?

    // ❌ Bad
    #expect(item.isEnabled == true)

### Use `#require`, Not Force-Unwrapping or Optional Chaining

Never force-unwrap optionals in tests. A `nil` crashes the test process instead of failing
cleanly. Optional chaining is also wrong, because it silently skips the expectation when the value
is `nil`.

    // ✅ Good
    let owner = try #require(item.owner)
    #expect(owner.name == "Alice")

    // ❌ Bad: crashes if nil
    #expect(item.owner!.name == "Alice")

    // ❌ Bad: passes if nil
    #expect(item.owner?.name == "Alice")

This applies to any optional access, including dictionary lookups, `first` and `last`, and `as?`
casts. Prefer `#require` to `guard let` in test bodies.

### Safe Array Access

Never subscript an array based on an earlier `#expect` of its count. If the expectation fails, the
test keeps going and the subscript crashes.

    // ✅ Good
    try #require(items.count == 2)
    #expect(items[0].name == "first")

    // ✅ Better
    let first = try #require(items.first)
    #expect(first.name == "first")

    // ✅ Best: no positional access
    #expect(items.map(\.name) == ["first", "second"])

### Unconditional Failures

When a path should never be reached in a passing test, use `Issue.record(_:)` with a descriptive
message, then `return`, because recording an issue doesn’t stop the test:

    guard case .success(let value) = result else {
        Issue.record("Expected .success, got \(result)")
        return
    }

### Main Actor

Mark test structs and functions `@MainActor` when testing main-actor-isolated code, such as view
models.


## Reducing Repetition

### Shared Setup in `init`

When most tests in a struct need the same inputs or mocks, create them in the struct’s `init`.
Each test then shows only what makes it different.

    struct ItemLibraryTests: RandomValueGenerating {
        var randomNumberGenerator = makeRandomNumberGenerator()

        let mockStore: MockItemStore
        let library: ItemLibrary


        init() {
            mockStore = MockItemStore()
            mockStore.itemsStub = ThrowingStub(defaultReturnValue: [])

            library = ItemLibrary(store: mockStore)
        }
    }

### Helper Functions

When several tests build similar objects, extract a private helper with clear parameter defaults.

### Keep Test-Specific Setup in the Test

Shared setup covers the common baseline. Anything specific to one scenario goes in that test’s
`// set up` section, so readers don’t have to look elsewhere for context.


## DevFoundation Specifics

### Networking

Networking tests never use the network. Use `SimulatedURLRequestLoader` or a mock
`URLRequestLoader` to supply responses.
