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

/// An enumeration that defines the scope of a dependency within a container.
/// The `Scope` enum specifies how instances of dependencies are managed within a dependency injection container.
/// It determines whether a new instance is created each time the dependency is resolved, or whether a single instance
/// is reused throughout the container's lifetime.
///
/// - `transient`: A new instance of the dependency is created every time it is resolved.
/// - `container`: A single instance of the dependency is created and reused throughout the container's lifetime.
public enum Scope {
    /// A new instance of the dependency is created every time it is resolved.
    case transient

    /// A single instance of the dependency is created and reused throughout the container's lifetime.
    case container
}
