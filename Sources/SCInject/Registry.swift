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

/// A protocol that defines an interface for registering dependencies within a container.
/// The `Registry` protocol allows the registration of dependencies with different scopes and names.
/// Implementations of this protocol are responsible for storing the provided closures that create instances of the
/// registered types.
/// These registered dependencies can later be resolved by a `Resolver`.
/// This protocol is typically implemented by dependency injection containers, such as `DefaultContainer`.
public protocol Registry {
    /// Registers a dependency with a transient scope.
    /// - Parameter type: The type of the dependency to register.
    /// - Parameter closure: A closure that provides the instance of the dependency.
    func register<T>(_ type: T.Type, closure: @escaping (Resolver) -> T)

    ///  Registers a dependency with a specified scope.
    /// - Parameter type: The type of the dependency to register.
    /// - Parameter scope: The scope in which the dependency should be resolved.
    /// - Parameter closure: A closure that provides the instance of the dependency.
    func register<T>(_ type: T.Type, _ scope: Scope, closure: @escaping (Resolver) -> T)

    ///  Registers a named dependency with a transient scope.
    /// - Parameter type: The type of the dependency to register.
    /// - Parameter name: The name associated with the dependency.
    /// - Parameter closure: A closure that provides the instance of the dependency.
    func register<T>(_ type: T.Type, name: String, closure: @escaping (Resolver) -> T)

    ///  Registers a named dependency with a specified scope.
    /// - Parameter type: The type of the dependency to register.
    /// - Parameter name: The name associated with the dependency.
    /// - Parameter scope: The scope in which the dependency should be resolved.
    /// - Parameter closure: A closure that provides the instance of the dependency.
    func register<T>(_ type: T.Type, name: String, _ scope: Scope, closure: @escaping (Resolver) -> T)

    ///  Registers a named dependency with a transient scope.
    /// - Parameter type: The type of the dependency to register.
    /// - Parameter name: The name associated with the dependency.
    /// - Parameter closure: A closure that provides the instance of the dependency.
    func register<T>(_ type: T.Type, name: RegisterName, closure: @escaping (Resolver) -> T)

    ///  Registers a named dependency with a specified scope.
    /// - Parameter type: The type of the dependency to register.
    /// - Parameter name: The name associated with the dependency.
    /// - Parameter scope: The scope in which the dependency should be resolved.
    /// - Parameter closure: A closure that provides the instance of the dependency.
    func register<T>(_ type: T.Type, name: RegisterName, _ scope: Scope, closure: @escaping (Resolver) -> T)
}
