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

class TestClass1 {
    let rawValue: String

    init(value: String) {
        rawValue = value
    }
}

class TestClass2 {
    let value: TestClass1

    init(value: TestClass1) {
        self.value = value
    }
}

actor TestActor1 {
    let rawValue: String

    init(value: String) async {
        // Simulate async initialization
        try? await Task.sleep(nanoseconds: 1_000_000) // 1ms
        rawValue = value
    }
}

actor TestActor2 {
    let value: TestActor1

    init(value: TestActor1) async {
        // Simulate async initialization
        try? await Task.sleep(nanoseconds: 1_000_000) // 1ms
        self.value = value
    }
}
