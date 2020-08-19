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

public struct AnyLayout {
    private let box: _AnyLayoutBox

    public init<T>(_ type: T.Type) {
        box = _AnyLayout<T>()
    }

    public var size: Int { box.size }

    public var alignment: Int { box.alignment }

    public var stride: Int { box.stride }

    public var metadata: Metadata { Metadata(rawValue: box.metadata) }

    @_transparent
    var _size: Int { box.size }

    @_transparent
    var _alignment: Int { box.alignment }

    @_transparent
    var _stride: Int { box.stride }

    @_transparent
    var _metadata: UnsafePointer<Metadata.RawValue> { box.metadata }
}

extension AnyLayout: Equatable {
    public static func == (lhs: AnyLayout, rhs: AnyLayout) -> Bool {
        lhs.metadata == rhs.metadata
    }

    public static func == <T>(lhs: AnyLayout, rhs: T.Type) -> Bool {
        lhs._metadata == unsafeBitCast(rhs as Any.Type, to: UnsafePointer<Metadata.RawValue>.self)
    }

    public static func == <T>(lhs: T.Type, rhs: AnyLayout) -> Bool {
        unsafeBitCast(lhs as Any.Type, to: UnsafePointer<Metadata.RawValue>.self) == rhs._metadata
    }

    public static func == (lhs: AnyLayout, rhs: Any.Type) -> Bool {
        lhs._metadata == unsafeBitCast(rhs, to: UnsafePointer<Metadata.RawValue>.self)
    }

    public static func == (lhs: Any.Type, rhs: AnyLayout) -> Bool {
        unsafeBitCast(lhs, to: UnsafePointer<Metadata.RawValue>.self) == rhs._metadata
    }

    public static func ~= <T>(pattern: T.Type, value: AnyLayout) -> Bool {
        value._metadata == unsafeBitCast(pattern as Any.Type, to: UnsafePointer<Metadata.RawValue>.self)
    }

    public static func ~= (pattern: Any.Type, value: AnyLayout) -> Bool {
        value._metadata == unsafeBitCast(pattern, to: UnsafePointer<Metadata.RawValue>.self)
    }
}

private protocol _AnyLayoutBox {
    var size: Int { get }
    var alignment: Int { get }
    var stride: Int { get }
    var metadata: UnsafePointer<Metadata.RawValue> { get }
}

private struct _AnyLayout<T>: _AnyLayoutBox {
    @_transparent
    var size: Int {
        MemoryLayout<T>.size
    }

    @_transparent
    var alignment: Int {
        MemoryLayout<T>.alignment
    }

    @_transparent
    var stride: Int {
        MemoryLayout<T>.size
    }

    @_transparent
    var metadata: UnsafePointer<Metadata.RawValue> {
        unsafeBitCast(T.self as Any.Type, to: UnsafePointer<Metadata.RawValue>.self)
    }
}
