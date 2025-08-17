# Test Mock Documentation

This document outlines the patterns and conventions for writing test mocks in Swift.

Its helpful to read the [Dependency Injection guide](DependencyInjection.md) before reading this
guide, as it introduces core principles for how we think about dependency injection.


## Overview

We use a consistent approach to mocking based on the DevTesting package’s `Stub` and `ThrowingStub`
types. All mocks follow standardized patterns that make them predictable, testable, and
maintainable.


## When to Mock vs. Use Types Directly

Create mock protocols when

  - The type has **non-deterministic behavior** (network calls, file I/O, time-dependent operations)
  - You need to **control or observe the behavior** in tests
  - The type’s behavior **varies across environments**

Use types directly when

  - The type has **deterministic, predictable behavior**
  - Testing with the real implementation provides **sufficient coverage**
  - Creating abstractions adds **complexity without testing benefits**

It’s worth pointing out that the following foundational types should be used directly.

  - **`NotificationCenter`**: Posting and observing notifications is predictable
  - **`UserDefaults`**: Simple key-value storage with consistent behavior
  - **`Bundle`**: Resource loading behavior is consistent and testable
  - **`EventBus`**: Synchronous event dispatching with deterministic outcomes


## Core Mock Patterns

### 1. Stub-Based Architecture

All mocks use `DevTesting`’s `Stub<Input, Output>` or `ThrowingStub<Input, Output, Error>` types
for function and property implementations:

    import DevTesting


    final class MockService: ServiceProtocol {
        nonisolated(unsafe) var performActionStub: Stub<String, Bool>!


        func performAction(_ input: String) -> Bool {
            performActionStub(input)
        }
    }

**Key characteristics:**

  - Properties are marked `nonisolated(unsafe)` for Swift 6 concurrency
  - Stub properties are force-unwrapped (`!`). Tests must configure them.
  - Function implementations simply call the corresponding stub


### 2. Argument Structures for Complex Parameters

When functions have multiple parameters, create dedicated argument structures:

    final class MockTelemetryDestination: TelemetryDestination {
        struct LogErrorArguments {
            let error: any Error
            let attributes: [String : any Encodable]
        }


        nonisolated(unsafe) var logErrorStub: Stub<LogErrorArguments, Void>!


        func logError(_ error: some Error, attributes: [String : any Encodable]) {
            logErrorStub(.init(error: error, attributes: attributes))
        }
    }

**Benefits:**

  - Simplifies stub configuration in tests
  - Provides clear parameter documentation
  - Enables easy verification of function calls


### 3. Property-Only Services

For services that only expose properties (like `MockAppServices`), each property delegates to a
stub:

    final class MockAppServices: PlatformAppServices {
        nonisolated(unsafe) var stylesheetStub: Stub<Void, Stylesheet>!
        nonisolated(unsafe) var telemetryEventLoggerStub: Stub<Void, any TelemetryEventLogging>!


        var stylesheet: Stylesheet {
            stylesheetStub()
        }


        var telemetryEventLogger: any TelemetryEventLogging {
            telemetryEventLoggerStub()
        }
    }


### 4. Generic Mock Types

For protocols with associated types, create generic mocks:

    struct MockTelemetryEvent<EventData>: TelemetryEvent
    where EventData: Encodable & Sendable {
        let name: TelemetryEventName
        var eventData: EventData
    }


    extension MockTelemetryEvent: Equatable where EventData: Equatable { }
    extension MockTelemetryEvent: Hashable where EventData: Hashable { }


**Pattern:**

  - Use generic parameters for flexible data types
  - Add conditional conformances for `Equatable` and `Hashable` when possible
  - Maintain protocol requirements while allowing test customization


### 5. Simple Error Mocks

For testing error scenarios, use simple enum-based errors:

    enum MockError: Error, CaseIterable, Hashable, Sendable {
        case error1
        case error2
        case error3
    }

**Characteristics:**

  - Implement `CaseIterable` for easy test iteration
  - Include `Hashable` and `Sendable` for Swift 6 compatibility
  - Use descriptive but simple case names


## Mock Organization

### File Structure and Organization

#### Directory Structure:
    Tests/
    ├── [PackageName]Tests/                     # Package-specific tests
    │   ├── Unit Tests/
    │   │   └── [ModuleName]                    # Feature-specific tests
    │   │       └── [ProtocolName]Tests.swift   
    │   └── Testing Support/                    # Mock objects and test utilities
    │       ├── Mock[ProtocolName].swift        # Mock implementations
    │       ├── MockError.swift                 # Test-specific error types
    │       └── RandomValueGenerating+[ModuleName].swift # Random value extensions

#### File Placement Guidelines:

- **Unit Test files**: Place in `Tests/[PackageName]/Unit Tests/`, matching the path of the source file in 
  the directory structure under `Sources/`
- **Mock objects**: Always place in `Tests/[PackageName]/Testing Support/` directories
- **One mock per file**: Each protocol should have its own dedicated mock file
- **Sharing mocks**: Do not share mocks between Packages. If the same Mock is needed across 
  multiple packages, duplicate it. 

### Naming Conventions

  - **File names**: `Mock[ProtocolName].swift`
  - **Type names**: `Mock[ProtocolName]`
  - **Argument structures**: `[FunctionName]Arguments`
  - **Stub properties**: `[functionName]Stub`


## Special Patterns

### 1. Static Stubs for Initializers

When mocking types with custom initializers, use static stubs:

    final class MockSubapp: Subapp {
        struct InitArguments {
            let appConfiguration: AppConfiguration
            let subappServices: any SubappServices
        }


        nonisolated(unsafe) static var initStub: Stub<InitArguments, Void>!


        init(appConfiguration: AppConfiguration, subappServices: any SubappServices) async {
            Self.initStub(.init(appConfiguration: appConfiguration, subappServices: subappServices))
        }
    }


### 2. Default Stub Values

For functions that might not be called in every test, provide default stub values:

    final class MockSubapp: Subapp {
        // Initialize to non-nil to avoid crashes in tests that don’t configure this stub
        nonisolated(unsafe) var installTelemetryBusEventHandlersStub: Stub<
            TelemetryBusEventObserver,
            Void
        > = .init()
    }


### 3. Protocol Imports with @testable

Import protocols under test with `@testable` when accessing internal details:

    import AppPlatform
    @testable import protocol AppPlatform.PlatformAppServices
    @testable import protocol Telemetry.TelemetryDestination


## Usage in Tests

### 1. Typical Test Setup

    @Test
    mutating func testEventLogging() throws {
        let mockDestination = MockTelemetryDestination()
        mockDestination.logEventStub = .init()  // Initialize stub

        let logger = TelemetryEventLogger(telemetryDestination: mockDestination)
        logger.logEvent(someEvent)

        // Verify the call was made
        #expect(mockDestination.logEventStub.calls.count == 1)

        // Extract and verify arguments
        let arguments = try #require(mockDestination.logEventStub.callArguments.first)
        #expect(arguments.name == expectedEventName)
        #expect(arguments.attributes["key"] as? String == "expectedValue")
    }


### 2. Return Value Configuration

    @Test
    func testServiceCall() {
        let mockServices = MockAppServices()
        mockServices.stylesheetStub = Stub(defaultReturnValue: .standard)

        let result = systemUnderTest.processWithServices(mockServices)

        // Verify the service was called
        #expect(mockServices.stylesheetStub.calls.count == 1)
    }


### 3. Argument Verification Patterns

    @Test
    mutating func testComplexMethodCall() throws {
        let mockDestination = MockTelemetryDestination()
        mockDestination.logErrorStub = .init()

        let error = MockError.error1
        let attributes = ["key": "value"]

        logger.logError(error, attributes: attributes)

        // Verify call count
        #expect(mockDestination.logErrorStub.calls.count == 1)

        // Extract and verify arguments
        let arguments = try #require(mockDestination.logErrorStub.callArguments.first)
        #expect(arguments.error as? MockError == error)
        #expect(arguments.attributes["key"] as? String == "value")
    }


## Best Practices

  1. **Always configure stubs**: Force-unwrapped stubs will crash if not configured
  2. **Use argument structures**: Simplifies complex parameter verification
  3. **Leverage DevTesting**: Use the package’s call tracking and verification capabilities
  4. **Keep mocks simple**: Avoid complex logic in mock implementations
  5. **Group related mocks**: Place mocks in appropriate Testing Support directories
  6. **Follow naming conventions**: Consistent naming improves maintainability
  7. **Use Swift Testing**: Leverage `@Test`, `#expect()`, and `#require()` for assertions


## Thread Safety

All mocks use `nonisolated(unsafe)` markings for Swift 6 compatibility. This assumes:

  - Tests run on a single thread or properly synchronize access
  - Stub configuration happens during test setup before concurrent access
  - Mock usage patterns don’t require additional synchronization

When mocking concurrent code, consider additional synchronization mechanisms if needed.
