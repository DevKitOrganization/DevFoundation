# DevFoundation Changelog


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
