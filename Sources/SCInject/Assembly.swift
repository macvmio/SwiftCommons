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

/// A protocol that defines a blueprint for assembling dependencies into a registry.
///
/// Types conforming to the `Assembly` protocol are responsible for registering dependencies within a `Registry`
/// instance.
/// These dependencies can later be resolved by a `Resolver` provided by an `Assembler`.
///
/// This protocol is typically used in conjunction with the `Assembler` class, which coordinates the assembly process
/// across multiple `Assembly` instances.
public protocol Assembly {
    /// Assembles and registers dependencies into the provided `Registry`.
    func assemble(_ registry: Registry)
}
