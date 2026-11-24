# Agent Guidelines

DevFoundation is a Swift package of foundational utilities for Apple platforms:
networking, an event bus, date providers, concurrency helpers, paging, remote
localization, and assorted utility types. It also includes `dfob`, a command-line tool
that obfuscates and deobfuscates data.


## Building and testing

  - `swift build` and `swift test` build and test the package.
  - `swift test --filter dfobTests` runs only the `dfob` tests.
  - Xcode test plans in `Build Support/Test Plans/` run the tests with coverage, as CI does.


## Writing style

  - Follow the [Markdown Style Guide](Documentation/MarkdownStyleGuide.md) for all Markdown.
  - **Use typographic quotes and apostrophes, not straight ones,** in all Markdown, all code
    documentation (doc comments and standalone comments), and all user-facing strings:
      - Apostrophes: ’ (U+2019), as in “it’s”
      - Single quotes: ‘ (U+2018) and ’ (U+2019)
      - Double quotes: “ (U+201C) and ” (U+201D)

    Straight quotes (`'` and `"`) are still correct in code itself: string literal delimiters,
    code spans, code blocks, identifiers, and configuration files.


## Attribution

Never credit an agent or other code generation tool. Don’t add `Co-Authored-By` trailers or
“Generated with” lines to commits or pull requests, and don’t name an agent in file headers,
comments, or documentation. File headers name the git user. The programmer who uses a tool is
accountable for the changes it helped make.


## Commits and pull requests

A commit message is a short summary of what the commit does, then a blank line and a bulleted list
of the changes, close to what a changelog would say. Messages are plain text with lines of 72
characters or fewer. A pull request uses its commit message: the title is the summary, and the
body is the bullets.

Add an entry to `CHANGELOG.md` for changes that affect the library’s users.


## Code

Follow these guides before writing or reviewing Swift:

  - [Dependency Injection](Documentation/DependencyInjection.md)
  - [Swift Style Guide](Documentation/SwiftStyleGuide.md)
  - [Testing Guidelines](Documentation/Testing/TestingGuidelines.md)
  - [Test Mocks](Documentation/Testing/TestMocks.md)
  - [Async Test Patterns](Documentation/Testing/AsyncTestPatterns.md)

Also:

  - Document and test every public API, and keep test coverage above 99%.
  - Setting `DateProviders.current` to an auto-updating date provider causes an infinite
    loop.


## Formatting and linting

  - `Tools/format` formats Swift with swift-format and Markdown with rumdl, in place.
  - `Tools/lint` checks both, plus comment line length, which swift-format doesn’t check.
  - Configuration is in `.swift-format` (120-character lines) and `.rumdl.toml` (100-character
    lines for Markdown).
  - `Tools/install-git-hooks` installs a pre-push hook that runs `Tools/lint`.

Run `Tools/lint` before considering a change done.
