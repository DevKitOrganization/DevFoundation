# Dependency Injection

This document outlines the dependency injection patterns and conventions that I like to use in my
Swift code.

After reading this doc, take a look at the [Test Mocks guide](TestMocks.md) for specific guidance
about how to write mocks.


## When to Use Dependency Injection

Dependency injection should be used for types that exhibit **significant non-deterministic
behavior**. The goal is to enable testing by making unpredictable behavior controllable and
observable.


## Dependencies vs. Parameters

When designing initializers, distinguish between **dependencies** (which should be injected) and
**parameters** (which should be passed directly):

### Dependencies

Dependencies are anything you would want to mock for testing:

  - Domain models and business logic collaborators
  - App services and cross-cutting concerns (networking, logging, analytics)
  - External systems and OS services


### Parameters

Parameters are typically configuration, input values, or behavioral modifiers

  - **Data and configuration**: Value types, strings, numbers, and configuration types
  - **Communication patterns**: Delegates and callback protocols
  - **Dependency injection constructs**: The containers that hold your dependencies

### Example

    init(
        // Dependencies (injected)
        dependencies: Dependencies,

        // Parameters (passed directly)
        delegate: UserServiceDelegate,
        initialUserID: String
    )

### Parameter Ordering

**The dependency injection construct (`dependencies` or `dependencyProvider`) must always be the
first parameter** in an initializer. This creates consistency across the codebase and makes the
dependency injection pattern immediately recognizable.


## Dependency Lifecycle Patterns

Dependencies fall into two categories based on their lifecycle:

### 1. Instance Dependencies

These are dependencies that are instantiated once and reused throughout the lifetime of the
consuming type. Examples include:

  - Network clients
  - App services
  - Domain models

### 2. Transient Dependencies

These are dependencies that need to be created fresh each time they’re used. Examples include:

  - View models created on-demand for efficiency (only when navigating to a view)
  - Domain models created with specific runtime inputs that change over time


## Dependency Injection Patterns

We use three dependency injection patterns in this codebase. The **Dependencies Struct** and
**Dependency Provider** patterns are useful when your type is more complex, has many dependencies,
or has a more fluidly defined scope. **Direct injection** is useful for simple types with stable
dependencies. View models must use either the **Dependencies Struct** or **Dependency Provider**
patterns since their functionality tends to be more fluid and change over time. Other types can use
any of the three patterns based on your best judgment.


### Dependencies Struct

Use this pattern when **all dependencies are instance dependencies**.

Create a nested `Dependencies` struct within your type that holds all required dependencies:

    final class UserService {
        struct Dependencies {
            let networkClient: any NetworkClient
            let telemetryEventLogger: any TelemetryEventLogging
            let userInfoProvider: any UserInfoProvider
        }


        private let dependencies: Dependencies


        init(dependencies: Dependencies) {
            self.dependencies = dependencies
        }
    }


### Dependency Providers

Use this pattern when you have **any transient dependencies**.

Create a nested `DependencyProviding` protocol that declares:

  - **Properties** for instance dependencies
  - **Factory functions** (prefixed with `make`) for transient dependencies

        extension UserService {
            protocol DependencyProviding {
                var networkClient: any NetworkClient { get }
                var telemetryEventLogger: any TelemetryEventLogging { get }

                func makeProfileViewModel() -> ProfileViewModel
                func makeUserSession(userID: String) -> any UserSession
            }
        }

Implement a nested `DependencyProvider` type for in-app use:

    extension UserService {
        struct DependencyProvider: DependencyProviding {
            let networkClient: any NetworkClient
            let telemetryEventLogger: any TelemetryEventLogging


            func makeProfileViewModel() -> ProfileViewModel {
                return ProfileViewModel(
                    dependencies: .init(
                        networkClient: networkClient,
                        telemetryEventLogger: telemetryEventLogger
                    )
                )
            }


            func makeUserSession(userID: String) -> any UserSession {
                return StandardUserSession(userID: userID, networkClient: networkClient)
            }
        }
    }
Consume the provider in your type:

    final class UserService {
        private let dependencyProvider: any DependencyProviding


        init(dependencyProvider: any DependencyProviding) {
            self.dependencyProvider = dependencyProvider
        }


        func showProfile() {
            let viewModel = dependencyProvider.makeProfileViewModel()
            // Navigate to profile view with viewModel…
        }


        func performUserAction(for userID: String) async {
            let session = dependencyProvider.makeUserSession(userID: userID)
            // Use session…
        }
    }

#### Testing Support

Create a mock provider for testing, using the patterns from [TestMocks.md](TestMocks.md):

    final class MockUserServiceDependencyProvider: UserService.DependencyProviding {
        nonisolated(unsafe) var networkClientStub: Stub<Void, any NetworkClient>!
        nonisolated(unsafe) var telemetryEventLoggerStub: Stub<Void, any TelemetryEventLogging>!
        nonisolated(unsafe) var makeProfileViewModelStub: Stub<Void, ProfileViewModel>!
        nonisolated(unsafe) var makeUserSessionStub: Stub<String, any UserSession>!


        var networkClient: any NetworkClient {
            return networkClientStub()
        }


        var telemetryEventLogger: any TelemetryEventLogging {
            return telemetryEventLoggerStub()
        }


        func makeProfileViewModel() -> ProfileViewModel {
            return makeProfileViewModelStub()
        }


        func makeUserSession(userID: String) -> any UserSession {
            return makeUserSessionStub(userID)
        }
    }


### Direct Injection

Use this pattern for simple types with stable dependencies. Direct injection **must not be used for
view models**.

Pass dependencies directly as individual parameters:

    final class ImageProcessor {
        private let imageCache: any ImageCaching
        private let telemetryEventLogger: any TelemetryEventLogging


        init(
            imageCache: any ImageCaching,
            telemetryEventLogger: any TelemetryEventLogging
        ) {
            self.imageCache = imageCache
            self.telemetryEventLogger = telemetryEventLogger
        }
    }

Direct injection works well for:

  - Types with stable, well-defined responsibilities
  - Components where dependency relationships are unlikely to change
  - Utility types with few dependencies
