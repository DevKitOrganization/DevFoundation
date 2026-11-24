---
description: Swift conventions beyond swift-format: file headers, spacing, generics, numerics
read-when: Writing or reviewing Swift, especially new files, doc comments, or generic declarations
---

# Swift Style Guide

swift-format enforces indentation, line length, trailing commas, and access-level defaults; run
`Tools/lint` to check and `Tools/format` to fix (see `.swift-format`). swift-format doesn’t check
the length of standalone or documentation comments, so `Tools/lint` also reports those over the
limit, and they need wrapping by hand. This guide covers the conventions the formatter doesn’t.


## Files

  - Attribute new files to the git user, not the agent: `Created by <git user.name> on
    MM/DD/YYYY`.
  - End every Swift file with exactly one blank line.


## Declarations

  - Follow the
    [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
  - Declare generic constraints in `where` clauses, not inline in the parameter list.
  - Prefer `Float64` to `Double` and `Float32` to `Float`.
  - Declare a type’s stored properties first, including those with observers, then its
    initializers, then its computed properties and functions. Computed properties are
    implementations like functions, so they go with functions rather than stored properties.
  - Complex types take their dependencies as the first initializer parameter. See
    [Dependency Injection](DependencyInjection.md).


## Doc comments

  - Document every public declaration.
  - A doc comment begins with a one-sentence summary, which can wrap onto more lines. swift-format
    lints this shape.
  - `///` is fine on private members when the member could reasonably become exposed from the
    module. Otherwise prefer `//`.
  - Omit `- Returns:` and `- Throws:` when they only restate the signature.


## Bodies and control flow

Empty function bodies and control flow are important lines that are easy to miss on one line, so
give them their own lines:

  - Put control flow statements on multiple lines, including early returns such as
    `guard X else { return }`.
  - Don’t write empty function bodies as `{}`. Span multiple lines and explain why the body is empty
    in a comment.

Example:

    guard let context else {
        return
    }


    func invalidate() {
        // Does nothing, because this cache never holds expired values.
    }


## Spacing

Use 2 blank lines between major sections:

  - Between the last property declaration and the first function or initializer
  - Between function, initializer, and computed property implementations at the same scope
  - Between top-level declarations (type, protocol, extension)
  - Before a MARK comment that separates major sections

Use 1 blank line for minor separations:

  - Between property declarations and nested type definitions
  - Between function requirements in a protocol
  - After a MARK comment

Example:

    struct ItemList {
        let store: any ItemStoring
        let id: String
        var items: [Item]


        init(store: any ItemStoring, id: String) {
            self.store = store
            self.id = id
            self.items = []
        }


        var isEmpty: Bool {
            // Implementation
        }


        func reload() {
            // Implementation
        }
    }


    // MARK: - Protocol

    protocol ItemStoring {
        func items() async throws -> [Item]

        func save(_ item: Item) async throws
    }
