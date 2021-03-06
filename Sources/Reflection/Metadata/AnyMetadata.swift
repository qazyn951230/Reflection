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

public struct AnyMetadata {
    private let box: _AnyMetadataBox

    var rawValue: UnsafeRawPointer {
        box.rawValue
    }

    public init<T>(_ value: T) where T: TargetMetadata {
        box = _AnyMetadata<T>(value)
    }

    public var kind: Metadata.Kind {
        box.kind
    }

    public func `as`<T>(_ type: T.Type) -> T? where T: TargetMetadata {
        box.as(type)
    }
}

private protocol _AnyMetadataBox {
    var kind: Metadata.Kind { get }
    var rawValue: UnsafeRawPointer { get }

    func `as`<T>(_ type: T.Type) -> T? where T: TargetMetadata
}

private final class _AnyMetadata<T>: _AnyMetadataBox where T: TargetMetadata {
    let value: T

    init(_ value: T) {
        self.value = value
    }

    var kind: Metadata.Kind {
        value.kind
    }

    var rawValue: UnsafeRawPointer {
        value.rawValue.reinterpretCast()
    }

    func `as`<T>(_ type: T.Type) -> T? where T: TargetMetadata {
        value as? T
    }
}
