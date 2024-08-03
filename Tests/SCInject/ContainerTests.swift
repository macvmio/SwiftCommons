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
@testable import SCInject
import XCTest

// swiftlint:disable identifier_name
final class ContainerTests: XCTestCase {
    func testRegister_transientClass() {
        // Given
        let container = DefaultContainer()
        container.register(TestClass1.self) { _ in
            TestClass1(value: "TestClass1_Instance")
        }
        container.register(TestClass2.self) { r in
            TestClass2(value: r.resolve(TestClass1.self))
        }

        // When
        let class1 = container.tryResolve(TestClass1.self)
        let class2 = container.tryResolve(TestClass2.self)
        let class1_id = container.tryResolve(TestClass1.self, id: "Test")
        let class2_id = container.tryResolve(TestClass2.self, id: "Test")
        let class1_id_second = container.tryResolve(TestClass1.self, id: .init(rawValue: "Test"))
        let class2_id_second = container.tryResolve(TestClass2.self, id: .init(rawValue: "Test"))
        let class1_second = container.tryResolve(TestClass1.self)
        let class2_second = container.tryResolve(TestClass2.self)

        // Then
        XCTAssertNotNil(class1)
        XCTAssertNotNil(class2)
        XCTAssertNotNil(class1_second)
        XCTAssertNotNil(class2_second)
        XCTAssertNil(class1_id)
        XCTAssertNil(class2_id)
        XCTAssertNil(class1_id_second)
        XCTAssertNil(class2_id_second)
        XCTAssertTrue(class1 !== class1_second)
        XCTAssertTrue(class2 !== class2_second)
        XCTAssertTrue(class2?.value !== class1)
    }

    func testRegister_transientClassWithId() {
        let second: Identifier = .init(rawValue: "second")
        let container = DefaultContainer()
        container.register(TestClass1.self) { _ in
            TestClass1(value: "TestClass1_Instance")
        }
        container.register(TestClass1.self, id: second) { _ in
            TestClass1(value: "TestClass1_Second_Instance")
        }
        container.register(TestClass2.self) { r in
            TestClass2(value: r.resolve(TestClass1.self, id: second))
        }

        // When
        let class1 = container.tryResolve(TestClass1.self)
        let class2 = container.tryResolve(TestClass2.self)
        let class1_id = container.tryResolve(TestClass1.self, id: second)
        let class2_id = container.tryResolve(TestClass2.self, id: second)

        // Then
        XCTAssertNotNil(class1)
        XCTAssertNotNil(class2)
        XCTAssertNotNil(class1_id)
        XCTAssertNil(class2_id)
        XCTAssertEqual(class1_id?.rawValue, "TestClass1_Second_Instance")
        XCTAssertEqual(class2?.value.rawValue, "TestClass1_Second_Instance")
        XCTAssertTrue(class1 !== class1_id)
        XCTAssertTrue(class2?.value !== class1_id)
    }
}

// swiftlint:enable identifier_name
