# Testing Guidelines for Claude Code

This file provides specific guidance for Claude Code when creating, updating, and maintaining 
Swift tests.

## Swift Testing Framework

**IMPORTANT**: This project uses **Swift Testing framework**, NOT XCTest. Do not apply XCTest 
patterns or conventions.

### Key Differences from XCTest

  - **Use `@Test` attribute** instead of function name conventions
  - **Use `#expect()` and `#require()`** instead of `XCTAssert*()` functions  
  - **Use `#expect(throws:)`** for testing error conditions instead of `XCTAssertThrows`
  - **No "test" prefixes** required on function names
  - **Struct-based test organization** instead of class-based

### Test Naming Conventions

  - **No "test" prefixes**: Swift Testing doesn't require "test" prefixes for function names
  - **Descriptive names**: Use clear, descriptive names like `initialLoadingState()` instead of 
    `testInitialLoadingState()`
  - **Protocol-specific naming**: For protocols with concrete implementations, name tests after 
    the concrete type (e.g., `StandardAuthenticationRemoteNotificationHandlerTests`)

### Unit Test Structure Conventions

Unit tests typically have 3 portions; setup, exercise, and expect.

  - **Setup**: Create the inputs or mocks necessary to exercise the unit under test
  - **Exercise**: Exercise the unit under test, usually by invoking a function using the inputs prepared during "Setup".
  - **Expect**: Expect one or more results to be true, using Swift Testing expressions.
  - More complicated tests may repeat the "exercise" and "expect" steps.
  - The beginning of each step should be clearly marked with a code comment, like:
      - // set up the test by preparing a mock authenticator
      - // exercise the test by initializing the data source
      - // expect that the loadUser stub is invoked once
  - If two sections overlap, only mention the most relevant information.

### Mock Testing Strategy

  - **Focus on verification**: Test that mocks are called correctly, not custom mock 
    implementations
  - **Use standard mocks**: All tests with injectable dependencies should use the same mock 
    types, not custom mock implementations.
  - **Always mock dependencies**: Even when not testing the mocked behavior, always use mocks 
    to supply dependencies to objects under test. 
  - **Minimal Stubbing**: Only stub functions that are relevant to the code under test, or 
    required for the test to execute successfully. 
      - Do *NOT* leave comments when stubs are omitted because they are irrelevant.

### ThrowingStub Usage

**CRITICAL**: DevTesting's `ThrowingStub` has very specific initialization patterns that 
differ from regular `Stub`. Using incorrect initializers will cause compilation errors.

#### Correct ThrowingStub Patterns:

    // For success cases:
    ThrowingStub(defaultReturnValue: value)

    // For error cases:  
    ThrowingStub(defaultError: error)

    // For cases where the value could be success or error:
    ThrowingStub(defaultResult: result)

    // For cases where the return type is Void and you don’t want to throw an error:
    ThrowingStub(defaultError: nil)

#### Common Mistakes to Avoid:

  - ❌ `ThrowingStub(throwingError: error)` - This doesn't exist  
  - ❌ `ThrowingStub()` with separate configuration - Must provide default in initializer

### Mock Object Patterns

Follow established patterns from `@Documentation/TestMocks.md`:

  - **Stub-based architecture**: Use `Stub<Input, Output>` and `ThrowingStub<Input, Output, Error>`
  - **Thread safety**: Mark stub properties with `nonisolated(unsafe)`
  - **Protocol conformance**: Mock the protocol, not the concrete implementation
  - **Argument structures**: For complex parameters, create dedicated argument structures

Example mock structure:

    final class MockProtocolName: ProtocolName {
        nonisolated(unsafe) var methodStub: Stub<InputType, OutputType>!
        
        func method(input: InputType) -> OutputType {
            methodStub(input)
        }
        
        nonisolated(unsafe) var throwingMethodStub: ThrowingStub<InputType, OutputType, any Error>!
        
        func throwingMethod(input: InputType) throws -> OutputType {
            try throwingMethodStub(input)
        }
    }


### Random Value Generation with Swift Testing

**IMPORTANT**: Swift Testing uses immutable test structs, but `RandomValueGenerating` requires 
`mutating` functions. This creates a specific pattern that must be followed.

#### Correct Pattern for Random Value Generation:

    @MainActor
    struct MyTests: RandomValueGenerating {
        var randomNumberGenerator = makeRandomNumberGenerator()
        
        @Test
        mutating func myTest() throws {
            let randomValue = randomAlphanumericString()
            // ... test logic
        }
    }

#### Key Requirements:

  - **Test struct must conform to `RandomValueGenerating`**
  - **Include `var randomNumberGenerator = makeRandomNumberGenerator()` property**
  - **Mark test functions as `mutating`** when using random value generation
  - **Test struct can be immutable** for tests that don't use random values

#### Dedicated Random Value Extensions:

  - **Dedicated files**: Create `RandomValueGenerating+[ModuleName].swift` files for random value 
    generation
  - **Centralized functions**: Move random value creation functions to these dedicated extension 
    files
  - **Consistent patterns**: Follow existing patterns from other modules (e.g., 
    `RandomValueGenerating+AppPlatform.swift`)
  - **Proper imports**: Include necessary `@testable import` statements for modules being 
    extended

Example structure:

    import DevTesting
    import Foundation

    @testable import ModuleName

    extension RandomValueGenerating {
        mutating func randomModuleSpecificType() -> ModuleType {
            return ModuleType(
                property: randomAlphanumericString()
            )
        }
    }

## File Organization

### Test Files

  - **Naming pattern**: `[ClassName]Tests.swift` in corresponding Tests directories
  - **Location**: Place in `Tests/[ModuleName]/[Category]/` directories
  - **One test file per class**: Each class should have its own dedicated test file
  - **Organize tests by function**: The tests for the function under test should be organized 
    together, preceded by a `// MARK: - [FunctionName]` comment.  

### Mock Files  

  - **Naming pattern**: `Mock[ProtocolName].swift`
  - **Location**: Place in `Tests/[ModuleName]/Testing Support/` directories
  - **Protocol-based**: Mock the protocol interface, not concrete implementations

### Random Value Extensions

  - **Naming pattern**: `RandomValueGenerating+[ModuleName].swift` 
  - **Location**: Place in `Tests/[ModuleName]/Testing Support/` directories
  - **Module-specific**: Create extensions for each module's unique types

### Import Patterns

  - **Testable imports**: Use `@testable import ModuleName` for modules under test
  - **Regular imports**: Use regular imports for testing frameworks and utilities
  - **Specific imports**: Import only what's needed to keep dependencies clear

## Test Coverage Guidelines

### Function Coverage
  - **Each function/getter**: Should have at least one corresponding test function
  - **Multiple scenarios**: Create additional test functions to cover edge cases and error 
    conditions
  - **Error paths**: Test both success and failure scenarios for throwing functions

### Error Handling in Tests

**CRITICAL**: Test functions that use `#expect(throws:)` must be marked with `throws`, 
otherwise you'll get "Errors thrown from here are not handled" compilation errors.

#### Correct Pattern:

    @Test
    func myTestThatExpectsErrors() throws {
        #expect(throws: SomeError.self) {
            try somethingThatThrows()
        }
    }

#### Common Mistake:

    // ❌ This will cause compilation error
    @Test  
    func myTestThatExpectsErrors() {
        #expect(throws: SomeError.self) {
            try somethingThatThrows()
        }
    }

### Main Actor Considerations
  - **Test isolation**: Mark test structs and methods with `@MainActor` when testing 
    MainActor-isolated code
  - **Mock conformance**: Ensure mocks properly handle MainActor isolation requirements
  - **Async testing**: Use proper async/await patterns for testing async code

### Dependency Injection Testing
  - **Mock all dependencies**: Create mocks for all injected dependencies to ensure proper 
    isolation
  - **Verify interactions**: Test that dependencies are called with correct parameters
  - **State verification**: Check both mock call counts and state changes in the system under 
    test

## Common Testing Patterns

### Testing Initialization

    @Test
    func initializationSetsCorrectDefaults() {
        let instance = ClassUnderTest()
        
        #expect(instance.property == expectedDefault)
    }

### Testing Dependency Calls

    @Test  
    mutating func methodCallsDependency() {
        let mock = MockDependency()
        mock.methodStub = Stub()
        
        let instance = ClassUnderTest(dependency: mock)
        instance.performAction()
        
        #expect(mock.methodStub.calls.count == 1)
    }

### Testing Error Scenarios

    @Test
    mutating func methodThrowsWhenDependencyFails() {
        let mock = MockDependency()
        let error = MockError(description: "Test error")
        mock.methodStub = ThrowingStub(defaultError: error)
        
        let instance = ClassUnderTest(dependency: mock)
        
        #expect(throws: MockError.self) {
            try instance.performAction()
        }
    }

### Testing Async Operations

    @Test
    mutating func asyncMethodCompletesSuccessfully() async throws {
        let mock = MockDependency()
        mock.asyncMethodStub = Stub(defaultReturnValue: expectedResult)
        
        let instance = ClassUnderTest(dependency: mock)
        let result = await instance.performAsyncAction()
        
        #expect(result == expectedResult)
        #expect(mock.asyncMethodStub.calls.count == 1)
    }

### Testing Async State Changes with Confirmations

When testing async state changes that occur through observation (like SwiftUI's `withObservationTracking`), use Swift Testing's `confirmation` API to properly wait for and verify the changes:

    @Test @MainActor
    mutating func stateChangesAsynchronously() async throws {
        // set up the test by creating the object and mocked dependencies
        let instance = ClassUnderTest()
        let mockDependency = MockDependency()
        instance.dependency = mockDependency
        
        // set up observation and confirmation for async state change
        try await confirmation { stateChanged in
            withObservationTracking {
                _ = instance.observableState
            } onChange: {
                stateChanged()
            }
            
            // exercise the test by triggering the state change
            try instance.performActionThatChangesState()
            
            // allow time for async state change to occur
            try await Task.sleep(for: .seconds(0.5))
        }
        
        // expect the final state to be correct
        #expect(instance.observableState == expectedFinalState)
    }

#### Key Points for Async State Testing:

  - **Use `confirmation`**: Wrap observation tracking with `confirmation { callback in }` to properly wait for async changes
  - **Call callback on change**: Invoke the confirmation callback in the `onChange` closure
  - **Allow processing time**: Use `Task.sleep(for:)` after triggering the action to allow async processing
  - **Mark test as async**: Use `async throws` and `await` for the confirmation
  - **Verify final state**: Check the final state after the confirmation completes

## Integration with Existing Documentation

This testing documentation supplements the main project documentation:

  - **Test Mocks**: See `@Documentation/TestMocks.md` for detailed mock object patterns
  - **Dependency Injection**: See `@Documentation/DependencyInjection.md` for dependency 
    patterns
  - **MVVM Testing**: See `@Documentation/MVVMForSwiftUI.md` for view model testing approaches

When in doubt, follow existing patterns from similar tests in the codebase and reference the 
established documentation for architectural guidance.
