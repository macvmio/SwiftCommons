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
        let class1_name = container.tryResolve(TestClass1.self, name: "Test")
        let class2_name = container.tryResolve(TestClass2.self, name: "Test")
        let class1_name_second = container.tryResolve(TestClass1.self, name: .init(rawValue: "Test"))
        let class2_name_second = container.tryResolve(TestClass2.self, name: .init(rawValue: "Test"))
        let class1_second = container.tryResolve(TestClass1.self)
        let class2_second = container.tryResolve(TestClass2.self)

        // Then
        XCTAssertNotNil(class1)
        XCTAssertNotNil(class2)
        XCTAssertNotNil(class1_second)
        XCTAssertNotNil(class2_second)
        XCTAssertNil(class1_name)
        XCTAssertNil(class2_name)
        XCTAssertNil(class1_name_second)
        XCTAssertNil(class2_name_second)
        XCTAssertTrue(class1 !== class1_second)
        XCTAssertTrue(class2 !== class2_second)
        XCTAssertTrue(class2?.value !== class1)
    }

    func testRegister_transientClassWithName() {
        let second: RegistrationName = .init(rawValue: "second")
        let container = DefaultContainer()
        container.register(TestClass1.self) { _ in
            TestClass1(value: "TestClass1_Instance")
        }
        container.register(TestClass1.self, name: second) { _ in
            TestClass1(value: "TestClass1_Second_Instance")
        }
        container.register(TestClass2.self) { r in
            TestClass2(value: r.resolve(TestClass1.self, name: second))
        }

        // When
        let class1 = container.tryResolve(TestClass1.self)
        let class2 = container.tryResolve(TestClass2.self)
        let class1_name = container.tryResolve(TestClass1.self, name: second)
        let class2_name = container.tryResolve(TestClass2.self, name: second)

        // Then
        XCTAssertNotNil(class1)
        XCTAssertNotNil(class2)
        XCTAssertNotNil(class1_name)
        XCTAssertNil(class2_name)
        XCTAssertEqual(class1_name?.rawValue, "TestClass1_Second_Instance")
        XCTAssertEqual(class2?.value.rawValue, "TestClass1_Second_Instance")
        XCTAssertTrue(class1 !== class1_name)
        XCTAssertTrue(class2?.value !== class1_name)
    }

    func testValidate() async throws {
        // Given
        let second: RegistrationName = .init(rawValue: "second")
        let container = DefaultContainer()
        container.register(TestClass1.self) { _ in
            TestClass1(value: "TestClass1_Instance")
        }
        container.register(TestClass1.self, name: second) { _ in
            TestClass1(value: "TestClass1_Second_Instance")
        }
        container.register(TestClass2.self) { r in
            TestClass2(value: r.resolve(TestClass1.self, name: second))
        }

        // When / Then
        try container.validate()
    }

    func testValidate_missingNamedType() async throws {
        // Given
        let container = DefaultContainer()
        container.register(TestClass1.self) { _ in
            TestClass1(value: "TestClass1_Instance")
        }
        container.register(TestClass2.self) { r in
            TestClass2(value: r.resolve(TestClass1.self, name: "second"))
        }

        // When / Then
        XCTAssertThrowsError(try container.validate()) { error in
            let error = error as? ContainerError
            XCTAssertEqual(error?.reason, "Failed to resolve given type -- TYPE=TestClass1 NAME=second")
            XCTAssertEqual(error?.type, "TestClass1")
            XCTAssertEqual(error?.name, "second")
        }
    }

    // MARK: - Async Tests

    func testRegisterAsync_transientActor() async {
        // Given
        let container = DefaultContainer()
        container.registerAsync(TestActor1.self) { _ in
            await TestActor1(value: "TestActor1_Instance")
        }
        container.registerAsync(TestActor2.self) { r in
            await TestActor2(value: r.resolveAsync(TestActor1.self))
        }

        // When
        let actor1 = await container.tryResolveAsync(TestActor1.self)
        let actor2 = await container.tryResolveAsync(TestActor2.self)
        let actor1_name = await container.tryResolveAsync(TestActor1.self, name: "Test")
        let actor2_name = await container.tryResolveAsync(TestActor2.self, name: "Test")
        let actor1_second = await container.tryResolveAsync(TestActor1.self)
        let actor2_second = await container.tryResolveAsync(TestActor2.self)

        // Then
        XCTAssertNotNil(actor1)
        XCTAssertNotNil(actor2)
        XCTAssertNotNil(actor1_second)
        XCTAssertNotNil(actor2_second)
        XCTAssertNil(actor1_name)
        XCTAssertNil(actor2_name)
        XCTAssertTrue(actor1 !== actor1_second)
        XCTAssertTrue(actor2 !== actor2_second)
        XCTAssertEqual(actor1?.rawValue, "TestActor1_Instance")
        XCTAssertEqual(actor1_second?.rawValue, "TestActor1_Instance")
    }

    func testRegisterAsync_transientActorWithName() async {
        // Given
        let second = "second"
        let container = DefaultContainer()
        container.registerAsync(TestActor1.self) { _ in
            await TestActor1(value: "TestActor1_Instance")
        }
        container.registerAsync(TestActor1.self, name: second) { _ in
            await TestActor1(value: "TestActor1_Second_Instance")
        }
        container.registerAsync(TestActor2.self) { r in
            await TestActor2(value: r.resolveAsync(TestActor1.self, name: second))
        }

        // When
        let actor1 = await container.tryResolveAsync(TestActor1.self)
        let actor2 = await container.tryResolveAsync(TestActor2.self)
        let actor1_name = await container.tryResolveAsync(TestActor1.self, name: second)
        let actor2_name = await container.tryResolveAsync(TestActor2.self, name: second)

        // Then
        XCTAssertNotNil(actor1)
        XCTAssertNotNil(actor2)
        XCTAssertNotNil(actor1_name)
        XCTAssertNil(actor2_name)
        XCTAssertTrue(actor1 !== actor1_name)
        XCTAssertEqual(actor1_name?.rawValue, "TestActor1_Second_Instance")
        XCTAssertEqual(actor2?.value.rawValue, "TestActor1_Second_Instance")
    }

    func testRegisterAsync_containerScope() async {
        // Given
        let container = DefaultContainer()
        container.registerAsync(TestActor1.self, .container) { _ in
            await TestActor1(value: "TestActor1_Singleton")
        }

        // When
        let actor1_first = await container.resolveAsync(TestActor1.self)
        let actor1_second = await container.resolveAsync(TestActor1.self)

        // Then
        XCTAssertTrue(actor1_first === actor1_second)
        XCTAssertEqual(actor1_first.rawValue, "TestActor1_Singleton")
    }

    func testMixedSyncAndAsync() async {
        // Given
        let container = DefaultContainer()
        container.register(TestClass1.self) { _ in
            TestClass1(value: "TestClass1_Instance")
        }
        container.registerAsync(TestActor1.self) { _ in
            await TestActor1(value: "TestActor1_Instance")
        }

        // When
        let class1 = container.tryResolve(TestClass1.self)
        let actor1 = await container.tryResolveAsync(TestActor1.self)

        // Then
        XCTAssertNotNil(class1)
        XCTAssertNotNil(actor1)
        XCTAssertEqual(class1?.rawValue, "TestClass1_Instance")
        XCTAssertEqual(actor1?.rawValue, "TestActor1_Instance")
    }
}

// swiftlint:enable identifier_name
