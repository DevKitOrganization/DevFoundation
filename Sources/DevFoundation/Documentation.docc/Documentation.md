# ``DevFoundation``

Access essential types and services for building your library or app’s foundation.


## Overview

DevFoundation is a Swift package that provides foundational utilities for Apple platforms. 
It offers comprehensive networking capabilities, an event bus, concurrency utilities, a system
for paging through data, and essential utility types for building robust applications.


## Topics

### Networking

- <doc:ConsumingWebServices>

### Type-Safe Events

- <doc:TypeSafeEvents>

### Paging

- <doc:PagingThroughData>

### Caching

- ``ExpiringValue``

### Observing Changes

- ``ObservableReference``

### Concurrency Utilities

- ``ExecutionGroup``
- ``withTimeout(_:priority:operation:)``
- ``Dispatch/DispatchQueue``
- ``Swift/Result``

### Encoding, Decoding, and JSON

- ``JSONValue``
- ``TopLevelDecoder``
- ``TopLevelEncoder``
- ``Foundation/JSONDecoder``
- ``Foundation/PropertyListDecoder``

### Expressing Retry Policies

- ``RetryPolicy``
- ``PredefinedDelaySequenceRetryPolicy``
- ``AggregateRetryPolicy``

### Generating Gibberish

- ``GibberishGenerator``

### Obfuscating and Deobfuscating Data

- ``Foundation/Data``

### Providing Dates for Testing

- ``DateProvider``
- ``DateProviders``

### Strongly-Typed IDs and Values 

- ``TypedExtensibleEnum``
- ``DottedHierarchicalID``
- ``SoftwareComponentID``

### Utility Protocols

- ``AnySendableHashable``
- ``HashableByID``
- ``IdentifiableBySelf``
- ``OptionalRepresentable``
- ``Swift/Optional``
