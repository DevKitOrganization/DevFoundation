# DevFoundation

DevFoundation is a Swift 6 package that provides useful types and protocols for building libraries
and apps on Apple platforms. It makes it easy to consume web services, mock web service responses,
page through data, post and handle type-safe events across multiple modules, and more.

DevFoundation is fully documented and tested and supports iOS 26+, macOS 26+, tvOS 26+, visionOS 26+,
and watchOS 26+.

View our [changelog](CHANGELOG.md) to see what’s new.


## Development Requirements

DevFoundation requires a Swift 6.2+ toolchain to build. We only test on Apple platforms. We follow
the [Swift API Design Guidelines][SwiftAPIDesignGuidelines]. We take pride in the fact that our
public interfaces are fully documented and tested. We aim for overall test coverage over 99%.

[SwiftAPIDesignGuidelines]: https://swift.org/documentation/api-design-guidelines/

### Development Setup

To set up the development environment:

  1. Run `Scripts/install-git-hooks` to install git hooks that automatically check code
     formatting on commits and run comprehensive tests before pushing.
  2. Use `Scripts/lint` to manually check code formatting at any time.
  3. Use `Scripts/test-all-platforms` to run tests on all supported platforms locally.


## Continuous Integration

DevFoundation uses GitHub Actions for continuous integration. The CI pipeline:

  - **Linting**: Automatically checks code formatting on all pull requests using `swift format`
  - **Testing**: Runs tests on macOS (iOS, tvOS, and watchOS testing disabled in CI due to
    stability issues)
  - **Coverage**: Generates code coverage reports using xccovPretty

For comprehensive cross-platform testing, developers should run `Scripts/test-all-platforms`
locally or rely on the pre-push git hook which automatically runs all platform tests before
pushing changes.


## Bugs and Feature Requests

Find a bug? Want a new feature? Create a GitHub issue and we’ll take a look.


## License

All code is licensed under the MIT license. Do with it as you will.
