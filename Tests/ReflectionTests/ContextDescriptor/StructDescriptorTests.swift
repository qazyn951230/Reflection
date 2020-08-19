// MIT License
//
// Copyright (c) 2017-present qazyn951230 qazyn951230@gmail.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import XCTest
@testable import Reflection

private struct Apple {
    let value: Int
    let text: String
}

private struct Banana<T> {
    let value: T
}

final class StructDescriptorTests: XCTestCase {
    let aType: Any.Type = Apple.self
    let bType: Any.Type = Banana<UInt>.self
    
    var aDescriptor: StructDescriptor!
    var bDescriptor: StructDescriptor!
    
    override func setUp() {
        aDescriptor = StructMetadata.load(from: aType).description
        bDescriptor = StructMetadata.load(from: bType).description
    }
    
    func testBasicProperty() {
        XCTAssertEqual(aDescriptor.name, "Apple")
        XCTAssertEqual(bDescriptor.name, "Banana")
        
        XCTAssertFalse(aDescriptor.isGeneric)
        XCTAssertTrue(bDescriptor.isGeneric)
        
        // parent is ReflectionTests module
        XCTAssertNotNil(aDescriptor.parent)
        XCTAssertNotNil(bDescriptor.parent)
        
        XCTAssertEqual(aDescriptor.fieldCount, 2)
        XCTAssertEqual(bDescriptor.fieldCount, 1)
    }
    
    static var allTests = [
        ("testBasicProperty", testBasicProperty),
    ]
}
