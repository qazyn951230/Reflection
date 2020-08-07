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

    public init<T>(_ value: T) where T: TargetMetadata {
        box = _AnyMetadata<T>(value)
    }

    public var kind: Metadata.Kind {
        box.kind
    }

    public var isValueMetadata: Bool {
        kind == .struct || kind == .enum
    }

    public var isStructMetadata: Bool {
        kind == .struct
    }

    public var isEnumMetadata: Bool {
        kind == .enum
    }

    public func `as`<T>(type: T.Type) -> T? where T: TargetMetadata {
        box.as(type: type)
    }
}

private class _AnyMetadataBox {
    var kind: Metadata.Kind {
        fatalError("`kind` has not been implemented")
    }

    func `as`<T>(type: T.Type) -> T? where T: TargetMetadata {
        fatalError("\(#function) has not been implemented")
    }
}

private final class _AnyMetadata<T>: _AnyMetadataBox where T: TargetMetadata {
    let value: T

    init(_ value: T) {
        self.value = value
    }

    override var kind: Metadata.Kind {
        value.kind
    }

    override func `as`<T>(type: T.Type) -> T? where T : TargetMetadata {
        value as? T
    }
}
