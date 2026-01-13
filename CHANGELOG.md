# DevFoundation Changelog


## 1.8.0: January 13, 2026

This release adds helpers for using remote content for localization.

  - Create a remote content bundle using `Bundle.makeRemoteContentBundle(at:localizedStrings:)`
  - Set the default remote content bundle using `Bundle.defaultRemoteContentBundle`
  - Access your remote localized strings (with a local fallback) using
    `#remoteLocalizedString(_:bundle:)` and `#remoteLocalizedString(format:bundle:_:)`


## 1.7.0: October 27, 2025

This is a small release that updates `ExpiringValue` to work better with `DateProvider`.
Specifically, the two initializers spelled `ExpiringValue.init(_:lifetimeDuration:)` have been
updated to include an `any DateProvider` parameter that defaults to `DateProviders.current`. The new
initializers are spelled `ExpiringValue.init(_:dateProvider:lifetimeDuration:)`.


## 1.6.0: October 24, 2025

This release introduces the `LiveQuery` subsystem, a set of types for managing search-as-you-type
functionality and other query-based operations. Live queries automatically handle scheduling,
deduplication, and caching as query fragments change.

  - `LiveQuery` is an `Observable` type that produces results as its query fragment changes. It
    coordinates between user input and result production, managing debouncing, duplicate removal,
    and error handling.
  - `LiveQueryResultsProducer` is a protocol that defines how to generate results for query
    fragments. Conforming types specify their scheduling strategy and implement result production
    logic.
  - `LiveQuerySchedulingStrategy` determines when results are generated: `.passthrough` for
    immediate results (best for cheap operations like local filtering), or `.debounce(_:)` to wait
    for typing to pause (best for expensive operations like network requests).

The live query subsystem is fully thread-safe, `Sendable`, and integrates seamlessly with SwiftUI
through the Observation framework.


## 1.5.0: October 22, 2025

This release adds the `UserSelection` type, a generic structure that manages a user’s selection with
a fallback to a default value. This type prioritizes explicit user choices over programmatic
defaults while maintaining separate tracking of both values, ensuring user preferences are never
accidentally overwritten by programmatic updates to defaults.


## 1.4.0: October 8, 2025

  - We’ve added `Duration`-based alternatives to all APIs that take a `TimeInterval`. Specifically,

      - We’ve added an overload of `DateProvider.offset(by:)` that takes a `Duration`.
      - We’ve added an overload of `ExpiringValue.init(_:lifetimeDuration:)` that takes a
        `Duration`.


## 1.3.0: October 8, 2025

  - We’ve added a computed property spelled `timeInterval` to `Duration`, which returns the
    duration as a `TimeInterval`.
  - We’ve updated the internal implementation of `ContextualEventBusObserver` to use an actor
    instead of a class with a dispatch queue. This should have no impact on consumers.


## 1.2.0: September 24, 2025

This release introduces the `ObservableReference` type and updates `ExecutionGroup` to enable
greater flexibility and testability.

  - This version updates the minimum supported versions of Apple’s OSes to 26.
  - `ObservableReference` is a simple reference type that conforms to `Observable`. This enables
    easily observing changes to the value.
  - There are now two variants of `ExecutionGroup.addTask(priority:operation:)`: the original
    version for non-throwing operations, and a new version for throwing operations. Both functions
    now have a generic parameter for the operation’s return type. Together, these changes allow us
    to return the created `Task`, which you can use to monitor its progress, get its result, or
    cancel it.


## 1.1.0: September 17, 2025

This release adds support for initializing `SequentialPager`s and `RandomAccessPager`s with loaded
pages. Both types’ initializers are now spelled `init(pageLoader:loadedPages:)`. The latter
parameter is an array of previously loaded pages that is empty by default.

This change enables more easily using pagers with previously loaded pages. For example, some web
services might return the first page of results as part of a larger payload. In such a case, the
page could be initialized with that first page, and the page loader will only be required to load
subsequent pages.


## 1.0.0: September 2, 2025

This is the first release of DevFoundation. The initial feature set includes

  - Web Service Consumption: Type-safe web service client with declarative request/response handling
    and conveniences for sending and receiving JSON data
  - HTTP Networking: Lower-level HTTP client with interceptor support and comprehensive HTTP types
    for status codes, methods, headers, and media types
  - Network Simulation and Testing: Sophisticated request mocking system with extensive request
    matching conditions and response generation capabilities for development and testing
  - Type-Safe Event System: Event bus for decoupled component communication with support for regular
    and identifiable events
  - Date Provider Abstraction: Protocol-based date providers for testing and time manipulation,
    including system, offset, and scaled providers
  - Concurrency Utilities: Async operation management including execution groups, timeout support,
    and enhanced DispatchQueue functionality
  - Data Pagination: Comprehensive paging system supporting both sequential and random access
    patterns
  - Additional utilities: Additional types and protocols for typed extensible enums, hierarchical
    IDs, expiring values, encoding/decoding helpers, a type-safe JSON value type, retry policies,
    and more
