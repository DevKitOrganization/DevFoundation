# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this
repository.


## Development Commands

### Building and Testing

  - **Build**: `swift build`
  - **Test all**: `swift test`
  - **Test specific target**: `swift test --filter DevFoundationTests` or
    `swift test --filter dfobTests`
  - **Test with coverage**: Use Xcode test plans in `Build Support/Test Plans/`
    (AllTests.xctestplan for all tests)

### Code Quality

  - **Lint**: `Scripts/lint` (uses `swift format lint --recursive --strict`)
  - **Format**: `swift format --recursive Sources/ Tests/`

### GitHub Actions

The repository uses GitHub Actions for CI/CD with the workflow in
`.github/workflows/VerifyChanges.yaml`. The workflow:

  - Lints code on PRs using `swift format`
  - Builds and tests on macOS only (iOS, tvOS, and watchOS builds disabled due to poor
    stability and performance in GitHub Actions)
  - Generates code coverage reports using xccovPretty
  - Requires Xcode 16.4 and macOS 15 runners

**Note**: For comprehensive cross-platform testing, use `Scripts/test-all-platforms` locally
or the pre-push git hook which runs all platform tests before pushing.


## Architecture Overview

DevFoundation is a Swift package providing foundational utilities for iOS, macOS, tvOS, visionOS,
and watchOS development. It consists of two main products:

### 1. DevFoundation Library

A comprehensive utility library with the following major components:

#### Networking Layer

  - **WebServiceClient**: Generic web service client with declarative request/response handling
  - **HTTPClient**: Lower-level HTTP client with request/response interceptors
  - **WebServiceRequest**: Protocol for defining web service requests
  - **BaseURLConfiguring**: Protocol for managing different base URLs (staging, production, etc.)
  - **HTTPClientInterceptor**: Protocol for request/response modification
  - **URLRequestLoader**: Protocol for loading URL requests

#### Event System

  - **EventBus**: Type-safe event bus for decoupled component communication
  - **BusEventObserver**: Protocol for observing bus events
  - **ContextualBusEventObserver**: Observer with contextual event handling

#### Date Management

  - **DateProvider**: Protocol for abstracting date/time sources
  - **DateProviders**: Namespace providing system, scaled, and offset date providers
  - **SystemDateProvider**: Default system date provider
  - **OffsetDateProvider**: Date provider with fixed offset
  - **ScaledDateProvider**: Date provider with time scaling

#### Concurrency Utilities

  - **ExecutionGroup**: Utility for managing concurrent operations
  - **DispatchQueue extensions**: Non-overcommitting and standard queue utilities

#### Paging System

  - **OffsetPage**: Protocol for pages with offset-based pagination
  - **SequentialPageLoader**: Protocol for loading pages sequentially
  - **SequentialPager**: Concrete pager for sequential page access
  - **RandomAccessPageLoader**: Protocol for loading pages at specific offsets
  - **RandomAccessPager**: Concrete pager for random access to pages

#### Utility Types

  - **AnySendableHashable**: Type-erased sendable hashable wrapper
  - **DottedHierarchicalID**: Hierarchical identifier with dot notation
  - **ExpiringValue**: Value wrapper with expiration logic
  - **GibberishGenerator**: Random string generation
  - **HashableByID**: Protocol for hashable-by-identity types
  - **IdentifiableBySelf**: Protocol for types identifiable by themselves
  - **JSONValue**: Unified JSON value representation
  - **OptionalRepresentable**: Protocol for types with optional representations
  - **RetryPolicy**: Configurable retry behavior for operations
  - **SoftwareComponentID**: Identifier for software components
  - **TopLevelCoding**: Protocol for top-level encoding/decoding
  - **TypedExtensibleEnum**: Type-safe extensible enumerations

### 2. dfob Command Line Tool

A command-line utility for data obfuscation/deobfuscation:

  - Uses Swift ArgumentParser for command-line interface
  - Supports obfuscation (`-O`) and deobfuscation (`-D`) operations
  - Handles file input/output or stdin/stdout
  - Implements custom obfuscation algorithm with configurable key and message sizes


## Key Design Patterns

### Generic Web Service Architecture

The networking layer uses heavy generics to provide type-safe, declarative web service access:

  - `WebServiceClient<BaseURLConfiguration, Authenticator>` for type-safe clients
  - Protocol-based request/response mapping
  - Interceptor pattern for request/response modification

### Protocol-Oriented Date Handling

Date providers use protocols to enable dependency injection and testing:

  - `DateProvider` protocol abstracts time sources
  - `DateProviders.current` provides global date provider configuration
  - Warning: Setting `DateProviders.current` to auto-updating providers causes infinite loops

### Thread-Safe Event Bus

The event bus uses Swift's new Synchronization framework:

  - `Mutex<[any BusEventObserver]>` for thread-safe observer management
  - Type-safe event posting with generic constraints
  - Support for both regular and identifiable events


## Dependencies

External dependencies managed via Swift Package Manager:

  - **swift-argument-parser**: Command-line argument parsing (dfob tool)
  - **swift-numerics**: Numeric utilities (testing)
  - **DevTesting**: Custom testing framework
  - **URLMock**: URL mocking for tests


## Testing

The codebase maintains >99% test coverage with comprehensive test suites:

  - All major components have corresponding test files
  - Mock implementations in `Tests/DevFoundationTests/Testing Helpers/`
  - Test utilities for date approximation, random value generation
  - Separate test plans for different components


## Testing and Mocking Standards

### Test Mock Architecture

The codebase uses a consistent stub-based mocking pattern built on the DevTesting framework:

#### Core Mock Patterns

  - **Stub-based mocks**: All mocks use `Stub<Input, Output>` or
    `ThrowingStub<Input, Output, Error>`
  - **Force-unwrapped stubs**: Stub properties are declared with `!` - tests must configure them
  - **Swift 6 concurrency**: All stub properties marked `nonisolated(unsafe)`
  - **Argument structures**: Complex parameters use dedicated structures (e.g.,
    `LogErrorArguments`)

#### Mock Organization

  - **File naming**: `Mock[ProtocolName].swift`
  - **Type naming**: `Mock[ProtocolName]`
  - **Stub properties**: `[functionName]Stub`
  - **Location**: `Tests/[ModuleName]/Testing Helpers/`

#### Test Patterns

  - Use `@Test` with Swift Testing framework
  - Use `#expect()` and `#require()` for assertions
  - Always configure stubs before use to avoid crashes
  - Leverage DevTesting's call tracking for verification

### Documentation Standards

Follow the project's Markdown Style Guide:

  - **Line length**: 100 characters max
  - **Code blocks**: Use 4-space indentation, not fenced blocks
  - **Lists**: Use `-` for bullets, align continuation lines with text
  - **Spacing**: 2 blank lines between major sections, 1 after headers
  - **Terminology**: Use "function" over "method", "type" over "class"


## Development Notes

  - Follows Swift API Design Guidelines
  - Uses Swift 6.2 with `ExistentialAny` and `MemberImportVisibility` features enabled
  - Minimum deployment targets: iOS 18+, macOS 15+, tvOS 18+, visionOS 2+, watchOS 11+
  - Reverse DNS prefix: `com.gauriar.devfoundation`
  - All public APIs are documented and tested
  - Test coverage target: >99%
