# Test Mock Documentation

This document outlines the patterns and conventions for writing test mocks in the Shopper iOS
codebase.


## Overview

The codebase uses a consistent approach to mocking based on the DevTesting framework's `Stub` type.
All mocks follow standardized patterns that make them predictable, testable, and maintainable.


## Core Mock Patterns

### 1. Stub-Based Architecture

All mocks use `DevTesting`’s `Stub<Input, Output>` or `ThrowingStub<Input, Output, Error>` types
for function and property implementations:

    import DevTesting


    final class MockService: ServiceProtocol {
        nonisolated(unsafe)
        var performActionStub: Stub<String, Bool>!


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


        nonisolated(unsafe)
        var logErrorStub: Stub<LogErrorArguments, Void>!


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
        nonisolated(unsafe)
        var stylesheetStub: Stub<Void, Stylesheet>!

        nonisolated(unsafe)
        var telemetryEventLoggerStub: Stub<Void, any TelemetryEventLogging>!


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

### File Structure

    Tests/
    ├── AppPlatformTests/
    │   └── Testing Support/
    │       ├── MockAppServices.swift
    │       ├── MockBootstrapper.swift
    │       └── MockSubapp.swift
    └── TelemetryTests/
        └── Testing Support/
            ├── MockTelemetryDestination.swift
            ├── MockTelemetryEvent.swift
            └── MockError.swift


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


        nonisolated(unsafe)
        static var initStub: Stub<InitArguments, Void>!


        init(appConfiguration: AppConfiguration, subappServices: any SubappServices) async {
            Self.initStub(.init(appConfiguration: appConfiguration, subappServices: subappServices))
        }
    }


### 2. Default Stub Values

For functions that might not be called in every test, provide default stub values:

    final class MockSubapp: Subapp {
        // Initialize to non-nil to avoid crashes in tests that don't configure this stub
        nonisolated(unsafe)
        var installTelemetryBusEventHandlersStub: Stub<TelemetryBusEventObserver, Void> = .init()
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
  3. **Maintain protocol fidelity**: Mocks should behave like real implementations
  4. **Leverage DevTesting**: Use the framework's call tracking and verification capabilities
  5. **Keep mocks simple**: Avoid complex logic in mock implementations
  6. **Group related mocks**: Place mocks in appropriate Testing Support directories
  7. **Follow naming conventions**: Consistent naming improves maintainability
  8. **Use Swift Testing**: Leverage `@Test`, `#expect()`, and `#require()` for assertions


## Thread Safety

All mocks use `nonisolated(unsafe)` markings for Swift 6 compatibility. This assumes:

  - Tests run on a single thread or properly synchronize access
  - Stub configuration happens during test setup before concurrent access
  - Mock usage patterns don't require additional synchronization

When mocking concurrent code, consider additional synchronization mechanisms if needed.
