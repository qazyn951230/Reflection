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
    let bar = false
}

//let t: Any.Type = Foobar.self // type(of: text)
//test_print_all_kind(unsafeBitCast(t, to: UnsafeRawPointer.self))
//test_print_generic_context(unsafeBitCast(t, to: UnsafeRawPointer.self))
//test_print_properties(unsafeBitCast(t, to: UnsafeRawPointer.self))

//let data = StructMetadata.load(from: t)
//let fields = data.description.fields!
//for i in 0..<fields.fieldRecords().count {
//    print(data.fieldOffset(at: i) ?? -1)
//}

//let text = Text("Foobar")
//    .offset(CGSize.zero)

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

let bar = Foobar()
Swift.dump(bar)
//▿ Demo.Foobar
//- value: 12
//- bar: false

print("--------")
dump(bar)

//dump(text)
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
