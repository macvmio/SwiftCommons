# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftCommons is a collection of simple, small, and reusable Swift components created to support command line tools in [macvm](https://github.com/macvmio). The project currently provides SCInject, a minimalistic and efficient dependency injection container.

## Build Commands

This project uses `mise` as the task runner. Common commands:

```bash
# Build the project
make build
# or directly:
mise run build

# Run tests
make test
# or:
mise run test

# Run a single test
swift test --filter <test-name>

# Format code (uses SwiftFormat)
make format

# Lint code (uses SwiftLint and SwiftFormat)
make lint

# Auto-fix lint issues
make autocorrect

# Clean build artifacts
make clean

# Show build environment
make env
```

## Architecture

### SCInject - Dependency Injection Container

SCInject is the primary module providing a lightweight DI container with the following key components:

**Core Protocols:**
- `Container`: Combines Registry and Resolver functionality
- `Registry`: Interface for registering dependencies
- `Resolver`: Interface for resolving dependencies
- `Assembly`: Protocol for organizing dependency registrations into modular units

**Main Implementation:**
- `DefaultContainer`: Thread-safe container supporting hierarchical DI with parent-child relationships
- Supports two scopes:
  - `.transient`: Creates a new instance on each resolution
  - `.container`: Singleton behavior - creates once and reuses

**Registration Patterns:**
```swift
// Basic registration
container.register(MyService.self) { r in MyService() }

// With scope
container.register(MyService.self, .container) { r in MyService() }

// With name
container.register(MyService.self, name: "special") { r in MyService() }
```

**Resolution:**
```swift
let service = container.resolve(MyService.self)
let named = container.resolve(MyService.self, name: "special")
let optional = container.tryResolve(MyService.self)  // Returns nil if not registered
```

**Assembly Pattern:**
Use `Assembler` to organize registrations into modular `Assembly` units:
```swift
class MyAssembly: Assembly {
    func assemble(_ registry: Registry) {
        registry.register(MyService.self) { r in MyService() }
    }
}

let assembler = Assembler(container: DefaultContainer())
    .assemble([MyAssembly()])
let resolver = assembler.resolver()
```

**Validation:**
The container provides a `validate()` method to verify all dependencies can be resolved, useful for catching configuration issues during testing.

### Project Structure

- `Sources/SCInject/`: Main DI container implementation
  - `Container.swift`: Container protocol and DefaultContainer implementation
  - `Registry.swift`, `Resolver.swift`: Core protocols
  - `Assembly.swift`, `Assembler.swift`: Modular registration pattern
  - `Scope.swift`: Lifecycle management
  - `RegistrationName.swift`: Named registration support
- `Sources/SCInjectObjc/`: Objective-C support module
- `Tests/SCInjectTests/`: Test suite with XCTest

## Swift Language

- Project uses Swift 6 language mode (strict concurrency)
- Minimum platform versions:
  - macOS 10.13
  - iOS 15
  - visionOS 1
  - watchOS 9
  - tvOS 16

## Code Quality

The project enforces code quality through SwiftLint and SwiftFormat:

**SwiftFormat config (.swiftformat):**
- Max line width: 120 characters
- Swift version: 5.10
- Attributes on previous line for functions, types, and vars
- Wrap arguments/parameters before first

**SwiftLint config (.swiftlint.yml):**
- Disabled rules: trailing_comma, opening_brace, force_try
- Identifier name exceptions: `r`, `id`
- Type name exceptions: `T`

## Development Setup

```bash
# Install mise (if not already installed)
make setup

# First time setup
mise install
```

The project uses mise (.mise.toml) to manage tool versions:
- swiftlint 0.54.0
- swiftformat 0.53.3
