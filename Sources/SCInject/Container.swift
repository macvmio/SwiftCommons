//
// Copyright 2024 Marcin Iwanicki and contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/// A protocol that combines `Registry` and `Resolver` functionality, representing a container that can both register
/// and resolve dependencies.
public protocol Container: Registry, Resolver {}

/// A final class that implements the `Container` protocol, providing a dependency injection container with support for
/// registering and resolving dependencies.
/// The `DefaultContainer` class allows for hierarchical dependency injection with support for different scopes
/// (`transient` and `container`).
/// Dependencies can be registered with or without names, and resolved accordingly. If a dependency is not found in the
/// current container, it will attempt to resolve it from a parent container if one exists.
/// This class is thread-safe.
public final class DefaultContainer: Container {
    private let parent: DefaultContainer?
    private let lock = NSRecursiveLock()
    private let defaultScope = Scope.transient
    private var resolvers: [ResolverIdentifier: ReferenceResolver] = [:]

    public init(parent: DefaultContainer? = nil) {
        self.parent = parent
    }

    // MARK: - Registry

    public func register<T>(_ type: T.Type, closure: @escaping (Resolver) -> T) {
        register(type: type, name: nil, scope: nil, closure: closure)
    }

    public func register<T>(_ type: T.Type, _ scope: Scope, closure: @escaping (Resolver) -> T) {
        register(type: type, name: nil, scope: scope, closure: closure)
    }

    public func register<T>(_ type: T.Type, name: String, closure: @escaping (Resolver) -> T) {
        register(type: type, name: .init(rawValue: name), scope: nil, closure: closure)
    }

    public func register<T>(_ type: T.Type, name: String, _ scope: Scope, closure: @escaping (Resolver) -> T) {
        register(type: type, name: .init(rawValue: name), scope: scope, closure: closure)
    }

    public func register<T>(_ type: T.Type, name: RegistrationName, closure: @escaping (Resolver) -> T) {
        register(type: type, name: name, scope: nil, closure: closure)
    }

    public func register<T>(
        _ type: T.Type,
        name: RegistrationName,
        _ scope: Scope,
        closure: @escaping (Resolver) -> T
    ) {
        register(type: type, name: name, scope: scope, closure: closure)
    }

    // MARK: - Resolver

    public func resolve<T>(_ type: T.Type) -> T {
        guard let instance = tryResolve(type) else {
            ContainerError.raise(reason: "Failed to resolve given type", type: "\(type)", name: nil)
            fatalError()
        }
        return instance
    }

    public func resolve<T>(_ type: T.Type, name: String) -> T {
        resolve(type, name: .init(rawValue: name))
    }

    public func resolve<T>(_ type: T.Type, name: RegistrationName) -> T {
        guard let instance = tryResolve(type, name: name) else {
            ContainerError.raise(reason: "Failed to resolve given type", type: "\(type)", name: name.rawValue)
            fatalError()
        }
        return instance
    }

    // MARK: - Public

    public func tryResolve<T>(_ type: T.Type) -> T? {
        tryResolve(type: type, name: nil, container: self)
    }

    public func tryResolve<T>(_ type: T.Type, name: String) -> T? {
        tryResolve(type: type, name: .init(rawValue: name), container: self)
    }

    public func tryResolve<T>(_ type: T.Type, name: RegistrationName) -> T? {
        tryResolve(type: type, name: name, container: self)
    }

    /// Validates the dependency graph to ensure that all dependencies
    /// can be successfully resolved.
    ///
    /// This method attempts to resolve each dependency registered in the container,
    /// verifying that all dependencies can be satisfied without errors. If any
    /// dependency cannot be resolved, an error is thrown to indicate
    /// the issue.
    ///
    /// The validation process is performed recursively. If the container has a
    /// parent container, the method will also validate the parent container's
    /// dependency graph.
    ///
    /// - Throws:
    ///   - `ContainerError` if any dependency within the graph cannot be resolved.
    ///
    /// - Note:
    ///   This method is useful for ensuring that the dependency injection setup
    ///   is correct. It can be particularly valuable during development or testing
    ///   to catch configuration issues early.
    public func validate() throws {
        try ContainerError.rethrow {
            for resolver in resolvers {
                _ = resolver.value.resolve(with: self)
            }
        }
        try parent?.validate()
    }

    // MARK: - Private

    private func register<T>(
        type: T.Type,
        name: RegistrationName?,
        scope: Scope?,
        closure: @escaping (Resolver) -> T
    ) {
        lock.lock(); defer { lock.unlock() }
        let identifier = identifier(of: type, name: name)
        if resolvers[identifier] != nil {
            ContainerError.raise(reason: "Given type is already registered", type: "\(type)", name: name?.rawValue)
            fatalError()
        }
        resolvers[identifier] = makeResolver(scope ?? defaultScope, closure: closure)
    }

    private func tryResolve<T>(type: T.Type, name: RegistrationName? = nil, container: Container) -> T? {
        lock.lock(); defer { lock.unlock() }
        if let resolver = resolvers[identifier(of: type, name: name)] {
            return resolver.resolve(with: container) as? T
        }
        if let parent {
            return parent.tryResolve(type: type, name: name, container: container)
        }
        return nil
    }

    private func makeResolver(_ scope: Scope, closure: @escaping (Resolver) -> some Any) -> ReferenceResolver {
        switch scope {
        case .transient:
            TransientReferenceResolver(factory: closure)
        case .container:
            ContainerReferenceResolver(factory: closure)
        }
    }

    private func identifier(of type: (some Any).Type, name: RegistrationName?) -> ResolverIdentifier {
        ResolverIdentifier(
            name: name,
            typeIdentifier: ObjectIdentifier(type),
            description: String(describing: type)
        )
    }

    private struct ResolverIdentifier: Hashable {
        let name: RegistrationName?
        let typeIdentifier: ObjectIdentifier
        let description: String
    }
}

private protocol ReferenceResolver {
    func resolve(with resolver: Resolver) -> Any
}

private final class TransientReferenceResolver: ReferenceResolver {
    private let factory: (Resolver) -> Any

    init(factory: @escaping (Resolver) -> Any) {
        self.factory = factory
    }

    func resolve(with resolver: Resolver) -> Any {
        factory(resolver)
    }
}

private final class ContainerReferenceResolver: ReferenceResolver {
    private var instance: Any?

    private let factory: (Resolver) -> Any

    init(factory: @escaping (Resolver) -> Any) {
        self.factory = factory
    }

    func resolve(with resolver: Resolver) -> Any {
        if let instance {
            return instance
        }
        let newInstance = factory(resolver)
        instance = newInstance
        return newInstance
    }
}
