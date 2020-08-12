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

import Reflection
import CReflection
import SwiftUI

struct Foobar {
    let value = 12
}

//let a: [Any.Type] = [Int.self, Foobar.self, String.self]
//
//for t in a {
//    switch Metadata.load(from: t) {
//    case Int.self:
//        print("Int")
//    case Foobar.self:
//        print("Foobar")
//    default:
//        print("Any")
//    }
//}

let text = Text("Foobar")
    .offset(CGSize.zero)

let t: Any.Type = type(of: text)
//test_print_all_kind(unsafeBitCast(t, to: UnsafeRawPointer.self))
test_print_generic_context(unsafeBitCast(t, to: UnsafeRawPointer.self))

// test_print_all_kind
//let metadata = StructMetadata.load(from: t)
//print(metadata.kind)
////print(metadata.description.kind)
//var d: ContextDescriptor? = ContextDescriptor(other: metadata.description)
//while let t = d {
//    print(t.kind)
//    d = d?.parent
//}

// test_print_generic_context
let metadata = StructMetadata.load(from: t)
let descriptor = metadata.description
//let header = descriptor.trailingObjects(as: StructDescriptor.Header.self)
//print(header)
//print(header.pointee.base)
if let context = descriptor.genericContext() {
    print(context.rawValue)
}

//Swift.dump(text)
//▿ SwiftUI.ModifiedContent<SwiftUI.Text, SwiftUI._OffsetEffect>
//▿ content: SwiftUI.Text
//  ▿ storage: SwiftUI.Text.Storage.anyTextStorage
//    ▿ anyTextStorage: SwiftUI.(unknown context at $7fff43ee9c28).LocalizedTextStorage #0
//      - super: SwiftUI.AnyTextStorage
//      ▿ key: SwiftUI.LocalizedStringKey
//        - key: "Foobar"
//        - hasFormatting: false
//        - arguments: 0 elements
//      - table: nil
//      - bundle: nil
//  - modifiers: 0 elements
//▿ modifier: SwiftUI._OffsetEffect
//  ▿ offset: (0.0, 0.0)
//    - width: 0.0
//    - height: 0.0

//print("--------")

//dump(bar)

// https://unicode-table.com/en/blocks/box-drawing/
//SwiftUI.ModifiedContent<SwiftUI.Text, SwiftUI._OffsetEffect>
//├┬ content: SwiftUI.Text
//│├──┬ storage: SwiftUI.Text.Storage.anyTextStorage
//││  └──┬ anyTextStorage: SwiftUI.(unknown context at $7fff43ee9c28).LocalizedTextStorage #0
//││     ┝━━━ super: SwiftUI.AnyTextStorage
//││     ├──┬ key: SwiftUI.LocalizedStringKey
//││     │  ├─── key: "Foobar"
//││     │  ├─── hasFormatting: false
//││     │  └─── arguments: 0 elements
//││     ├─── table: nil
//││     └─── bundle: nil
//│└── modifiers: 0 elements
//└┬ modifier: SwiftUI._OffsetEffect
// └──┬ offset: (0.0, 0.0)
//    ├─── width: 0.0
//    └─── height: 0.0
