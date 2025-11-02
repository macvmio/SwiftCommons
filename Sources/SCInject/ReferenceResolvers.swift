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

// MARK: - Synchronous Resolvers

protocol ReferenceResolver {
    func resolve(with resolver: Resolver) -> Any
}

final class TransientReferenceResolver: ReferenceResolver {
    private let factory: (Resolver) -> Any

    init(factory: @escaping (Resolver) -> Any) {
        self.factory = factory
    }

    func resolve(with resolver: Resolver) -> Any {
        factory(resolver)
    }
}

final class ContainerReferenceResolver: ReferenceResolver {
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

// MARK: - Asynchronous Resolvers

protocol ReferenceAsyncResolver {
    func resolve(with resolver: Resolver) async -> Sendable
}

final class TransientReferenceAsyncResolver: ReferenceAsyncResolver {
    private let factory: (Resolver) async -> Sendable

    init(factory: @escaping (Resolver) async -> Sendable) {
        self.factory = factory
    }

    func resolve(with resolver: Resolver) async -> Sendable {
        await factory(resolver)
    }
}

actor ContainerReferenceAsyncResolver: ReferenceAsyncResolver {
    private var instance: Sendable?

    private let factory: @Sendable (Resolver) async -> Sendable

    init(factory: @escaping @Sendable (Resolver) async -> Any) {
        self.factory = factory
    }

    func resolve(with resolver: Resolver) async -> Sendable {
        if let instance {
            return instance
        }
        let instance = await factory(resolver)
        self.instance = instance
        return instance
    }
}
