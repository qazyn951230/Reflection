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
// import QuartzCore

class Foobar {
    let value: Int = 12
}

print(Metadata.readKind(from: Foobar.self))

//let t: Any.Type = Foobar.self
//run(unsafeBitCast(t, to: UnsafeRawPointer.self))

//let metadata = StructMetadata.load(from: Foobar.self)
//var d: ContextDescriptor? = ContextDescriptor(other: metadata.description)
//while let t = d {
//    print(t.kind)
//    d = d?.parent
//}

//let bar = Foobar(value: 12)
//Swift.dump(bar)
////▿ Demo.Foobar
////- value: 12
//
//// CustomDebugStringConvertible
//Swift.dump(CGSize.zero)
////▿ (0.0, 0.0)
////- width: 0.0
////- height: 0.0
//
//// CustomStringConvertible & CustomDebugStringConvertible
//Swift.dump(Array(repeating: 2, count: 2))
////▿ 2 elements
////- 2
////- 2

//print("--------")

//dump(bar)
