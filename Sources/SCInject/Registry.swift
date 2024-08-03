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

public protocol Registry {
    func register<T>(_ type: T.Type, closure: @escaping (Resolver) -> T)
    func register<T>(_ type: T.Type, _ scope: Scope, closure: @escaping (Resolver) -> T)

    func register<T>(_ type: T.Type, id: String, closure: @escaping (Resolver) -> T)
    func register<T>(_ type: T.Type, id: String, _ scope: Scope, closure: @escaping (Resolver) -> T)

    func register<T>(_ type: T.Type, id: Identifier, closure: @escaping (Resolver) -> T)
    func register<T>(_ type: T.Type, id: Identifier, _ scope: Scope, closure: @escaping (Resolver) -> T)
}
