/*
 * Copyright 2024 Marcin Iwanicki and contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

public protocol Container: Registry, Resolver {}

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
        register(type: type, id: nil, scope: nil, closure: closure)
    }

    public func register<T>(_ type: T.Type, _ scope: Scope, closure: @escaping (Resolver) -> T) {
        register(type: type, id: nil, scope: scope, closure: closure)
    }

    public func register<T>(_ type: T.Type, id: String, closure: @escaping (Resolver) -> T) {
        register(type: type, id: .init(rawValue: id), scope: nil, closure: closure)
    }

    public func register<T>(_ type: T.Type, id: String, _ scope: Scope, closure: @escaping (Resolver) -> T) {
        register(type: type, id: .init(rawValue: id), scope: scope, closure: closure)
    }

    public func register<T>(_ type: T.Type, id: Identifier, closure: @escaping (Resolver) -> T) {
        register(type: type, id: id, scope: nil, closure: closure)
    }

    public func register<T>(_ type: T.Type, id: Identifier, _ scope: Scope, closure: @escaping (Resolver) -> T) {
        register(type: type, id: id, scope: scope, closure: closure)
    }

    // MARK: - Resolver

    public func resolve<T>(_ type: T.Type) -> T {
        guard let instance = tryResolve(type) else {
            let message = errorMessage("Failed to resolve given type -- TYPE=\(type)")
            fatalError(message)
        }
        return instance
    }

    public func resolve<T>(_ type: T.Type, id: String) -> T {
        resolve(type, id: .init(rawValue: id))
    }

    public func resolve<T>(_ type: T.Type, id: Identifier) -> T {
        guard let instance = tryResolve(type, id: id) else {
            let message = errorMessage("Failed to resolve given type -- TYPE=\(type) ID=\(id.rawValue)")
            fatalError(message)
        }
        return instance
    }

    // MARK: - Public

    public func tryResolve<T>(_ type: T.Type) -> T? {
        tryResolve(type: type, id: nil, container: self)
    }

    public func tryResolve<T>(_ type: T.Type, id: String) -> T? {
        tryResolve(type: type, id: .init(rawValue: id), container: self)
    }

    public func tryResolve<T>(_ type: T.Type, id: Identifier) -> T? {
        tryResolve(type: type, id: id, container: self)
    }

    // MARK: - Private

    private func register<T>(
        type: T.Type,
        id: Identifier?,
        scope: Scope?,
        closure: @escaping (Resolver) -> T
    ) {
        lock.lock(); defer { lock.unlock() }
        let identifier = identifier(of: type, id: id)
        if resolvers[identifier] != nil {
            let message =
                errorMessage("Given type is already registered -- TYPE=\(type) ID=\(id?.rawValue ?? "nil")")
            fatalError(message)
        }
        resolvers[identifier] = makeResolver(scope ?? defaultScope, closure: closure)
    }

    private func tryResolve<T>(type: T.Type, id: Identifier? = nil, container: Container) -> T? {
        lock.lock(); defer { lock.unlock() }
        if let resolver = resolvers[identifier(of: type, id: id)] {
            return resolver.resolve(with: container) as? T
        }
        if let parent {
            return parent.tryResolve(type: type, id: id, container: container)
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

    private func identifier(of type: (some Any).Type, id: Identifier?) -> ResolverIdentifier {
        ResolverIdentifier(
            id: id,
            typeIdentifier: ObjectIdentifier(type),
            description: String(describing: type)
        )
    }

    private struct ResolverIdentifier: Hashable {
        let id: Identifier?
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
