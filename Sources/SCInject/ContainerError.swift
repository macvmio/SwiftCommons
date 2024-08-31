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
import SCInjectObjc

/// A `ContainerError` represents an error that occurs during the registration
/// or resolution in the dependency injection container.
///
/// This error type is used to encapsulate specific details about the failure,
/// including the reason for the error, the type of the service that caused the
/// error, and an optional name associated with the service.
public struct ContainerError: Error {
    /// A description of the reason why the error occurred.
    public let reason: String

    /// The type of the dependency that caused the error.
    public let type: String

    /// The name associated with the dependency.
    public let name: String?

    static func rethrow(_ closure: () -> Void) throws {
        try rethrow {
            try ContainerException.catch(closure)
        }
    }

    static func raise(reason: String, type: String, name: String?) {
        ContainerException.raise(reason: reason, type: type, name: nil)
    }

    // MARK: - Private

    private static func rethrow(_ closure: () throws -> Void) rethrows {
        do {
            try closure()
        } catch {
            let nsError = error as NSError
            // swiftlint:disable:next force_cast
            let reason = nsError.userInfo[NSLocalizedDescriptionKey] as! String

            // swiftlint:disable:next force_cast
            let type = nsError.userInfo[CSContainerExceptionTypeKey] as! String
            let name = nsError.userInfo[CSContainerExceptionNameKey] as? String
            throw ContainerError(reason: reason, type: type, name: name)
        }
    }
}
