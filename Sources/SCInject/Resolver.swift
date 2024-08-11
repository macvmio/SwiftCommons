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

/// A protocol that defines an interface for resolving dependencies from a container.
/// The `Resolver` protocol allows the retrieval of dependencies that have been previously registered in a container.
/// Dependencies can be resolved by their type, and optionally by a name, if they were registered with one.
/// Implementations of this protocol are typically provided by dependency injection containers, such as
/// `DefaultContainer`.
public protocol Resolver: AnyObject {
    /// Resolves a dependency by its type.
    /// - Parameter type: The type of the dependency to resolve.
    /// - Returns: An instance of the resolved dependency.
    /// - Note: The application will crash if the dependency cannot be resolved.
    func resolve<T>(_ type: T.Type) -> T

    /// Resolves a named dependency by its type.
    /// - Parameter type: The type of the dependency to resolve.
    /// - Parameter name: The name associated with the dependency.
    /// - Returns: An instance of the resolved dependency.
    /// - Note: The application will crash if the dependency cannot be resolved.
    func resolve<T>(_ type: T.Type, name: String) -> T

    /// Resolves a named dependency by its type.
    /// - Parameter type: The type of the dependency to resolve.
    /// - Parameter name: The `RegisterName` associated with the dependency.
    /// - Returns: An instance of the resolved dependency.
    /// - Note: The application will crash if the dependency cannot be resolved.
    func resolve<T>(_ type: T.Type, name: RegisterName) -> T
}
