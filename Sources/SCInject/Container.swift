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

    public func register<T>(_ type: T.Type, name: RegisterName, closure: @escaping (Resolver) -> T) {
        register(type: type, name: name, scope: nil, closure: closure)
    }

    public func register<T>(_ type: T.Type, name: RegisterName, _ scope: Scope, closure: @escaping (Resolver) -> T) {
        register(type: type, name: name, scope: scope, closure: closure)
    }

    // MARK: - Resolver

    public func resolve<T>(_ type: T.Type) -> T {
        guard let instance = tryResolve(type) else {
            let message = errorMessage("Failed to resolve given type -- TYPE=\(type)")
            fatalError(message)
        }
        return instance
    }

    public func resolve<T>(_ type: T.Type, name: String) -> T {
        resolve(type, name: .init(rawValue: name))
    }

    public func resolve<T>(_ type: T.Type, name: RegisterName) -> T {
        guard let instance = tryResolve(type, name: name) else {
            let message = errorMessage("Failed to resolve given type -- TYPE=\(type) NAME=\(name.rawValue)")
            fatalError(message)
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

    public func tryResolve<T>(_ type: T.Type, name: RegisterName) -> T? {
        tryResolve(type: type, name: name, container: self)
    }

    // MARK: - Private

    private func register<T>(
        type: T.Type,
        name: RegisterName?,
        scope: Scope?,
        closure: @escaping (Resolver) -> T
    ) {
        lock.lock(); defer { lock.unlock() }
        let identifier = identifier(of: type, name: name)
        if resolvers[identifier] != nil {
            let message =
                errorMessage("Given type is already registered -- TYPE=\(type) NAME=\(name?.rawValue ?? "nil")")
            fatalError(message)
        }
        resolvers[identifier] = makeResolver(scope ?? defaultScope, closure: closure)
    }

    private func tryResolve<T>(type: T.Type, name: RegisterName? = nil, container: Container) -> T? {
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

    private func identifier(of type: (some Any).Type, name: RegisterName?) -> ResolverIdentifier {
        ResolverIdentifier(
            name: name,
            typeIdentifier: ObjectIdentifier(type),
            description: String(describing: type)
        )
    }

    private struct ResolverIdentifier: Hashable {
        let name: RegisterName?
        let typeIdentifier: ObjectIdentifier
        let description: String
    }

    private func errorMessage(_ message: String) -> String {
        "SCInjectError - \(message)"
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
