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

/// A class responsible for assembling dependencies and providing a `Resolver` to resolve them.
///
/// The `Assembler` class serves as a coordinator for assembling an array of `Assembly` instances, which configure and
/// register dependencies within a `Container`.
/// Once the dependencies are assembled, the `Assembler` can return a `Resolver` for resolving the dependencies.
public final class Assembler {
    private let container: Container

    /// Initializes a new Assembler with the provided Container.
    public init(container: Container) {
        self.container = container
    }

    /// Assembles the provided list of Assembly instances, each of which is responsible for registering its dependencies
    /// within the container.
    @discardableResult
    public func assemble(_ assemblies: [Assembly]) -> Assembler {
        for assembly in assemblies {
            assembly.assemble(container)
        }
        return self
    }

    /// Provides the `Resolver` associated with the `Container` that was assembled.
    public func resolver() -> Resolver {
        container
    }
}
