# Markdown Style Guide

This document defines the Markdown formatting standards for documentation in the Shopper iOS
codebase.


## General Formatting

### Line Length

Keep all lines under **100 characters**. Break long sentences and paragraphs at natural points
to stay within this limit.

    ✅ Good:
    Faucibus consectetur lacinia nostra eros conubia nibh inceptos hendrerit, ante blandit 
    vulputate imperdiet amet porttitor torquent mattis.
    
    ❌ Bad:
    Faucibus consectetur lacinia nostra eros conubia nibh inceptos hendrerit, ante blandit vulputate imperdiet amet porttitor torquent mattis.


### Spacing

Use consistent spacing for visual hierarchy:

- **Between major sections**: 2 blank lines
- **After code blocks**: 1 blank line
- **Before subsections**: 1 blank line
- **After section headers**: 1 blank line

Example:

    ## Major Section

    Content here.


    ## Another Major Section

    ### Subsection

    Content after subsection header.

        code block here

    Content after code block.


## Headers

### Structure

Use consistent header hierarchy:

  - `#` for document title
  - `##` for major sections
  - `###` for subsections
  - `####` for sub-subsections (use sparingly)

### Numbering

Number subsections when they represent sequential steps or ordered items:

    ## Usage Patterns

    ### 1. Basic Setup
    ### 2. Advanced Configuration
    ### 3. Verification


## Code Blocks

### Indented Code Blocks

Use **4-space indentation** for all code blocks instead of fenced blocks:

    ✅ Good:
        import DevTesting

        final class MockService: ServiceProtocol {
            nonisolated(unsafe) var performActionStub: Stub<String, Bool>!
        }

    ❌ Bad:
    ```swift
    import DevTesting

    final class MockService: ServiceProtocol {
        nonisolated(unsafe) var performActionStub: Stub<String, Bool>!
    }
    ```


## Lists

### Unordered Lists

Use `-` as the bullet character for unordered lists. Place the hyphen 2 spaces from current
indentation level, followed by a space, then your text. When a bullet point spans multiple lines,
align continuation lines with the start of the text (not the hyphen). This ensures all text within a
bullet aligns vertically and makes proper indentation on continuation lines a matter of pressing tab
one or more times.

      - Turpis cubilia sit urna dis ultricies consequat massa hendrerit enim natoque.
      - Consectetur sapien posuere sit arcu finibus mattis dictumst dis, lectus ipsum in dictum
        lobortis bibendum enim, suscipit aliquet nulla porta erat id class purus.
          - Scelerisque massa rutrum dapibus placerat aenean tellus arcu cursus.
          - Iaculis, cubilia tristique efficitur bibendum urna imperdiet facilisis turpis hac,
            platea est habitant auctor quisque nec pulvinar fermentum sociosqu.
          - Parturient justo, venenatis nunc lobortis senectus tortor orci elementum consequat.
      - In nibh nisl venenatis bibendum neque mattis habitant tempor proin, tincidunt lobortis
        vulputate commodo.

Blank lines can be placed between bullets if it aids in readability.

### Ordered Lists

Use standard numbered lists for sequential items. Follow similar indentation rules as for unordered
lists. Note that the `.` characters in the bullets leads to some strange indentation, but this is
unavoidable.

      1. Turpis cubilia sit urna dis ultricies consequat massa hendrerit enim natoque.

      2. Consectetur sapien posuere sit arcu finibus mattis dictumst dis, lectus ipsum in dictum
         lobortis bibendum enim, suscipit aliquet nulla porta erat id class purus.

          1. Scelerisque massa rutrum dapibus placerat aenean tellus arcu cursus.
          2. Iaculis, cubilia tristique efficitur bibendum urna imperdiet facilisis turpis hac,
             platea est habitant auctor quisque nec pulvinar fermentum sociosqu.
          3. Parturient justo, venenatis nunc lobortis senectus tortor orci elementum consequat.

      4. In nibh nisl venenatis bibendum neque mattis habitant tempor proin, tincidunt lobortis
         vulputate commodo.


## Text Formatting

### Bold Text

Use bold for emphasis on key terms:

  - **File names**: `Mock[ProtocolName].swift`
  - **Type names**: `Mock[ProtocolName]`

### Code Spans

Use backticks for:

  - Type names: `Stub<Input, Output>`
  - Function names: `performAction(_:)`
  - File names: `MockAppServices.swift`
  - Keywords: `nonisolated(unsafe)`

### Terminology Consistency

Use consistent terminology throughout documents:

- Prefer "function" over "method" when referring to Swift functions
- Use "type" instead of "class" when referring generically to classes/structs/enums
- Use "property" for stored and computed properties


## File Structure Examples

Use indented text blocks for file structure diagrams:

    Tests/
    ├── Folder 1/
    │   └── Folder 2/
    │       ├── File1.swift
    │       └── File2.swift
    └── Folder 3/
        └── Folder 4/
            ├── File3.swift
            └── File4.swift


## Links and References

### Internal References

Use relative paths for internal documentation:

    See [Test Mock Documentation](TestMocks.md) for details.

### Code References

Reference specific locations using this pattern:

    The main implementation is in `Stub.swift:42-68`.
