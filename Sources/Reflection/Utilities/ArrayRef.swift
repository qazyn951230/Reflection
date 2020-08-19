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

public struct ArrayRef<Element, RawValue>: RandomAccessCollection {
    public typealias Index = Int
    public typealias SubSequence = ArrayRef

    public let data: UnsafePointer<RawValue>
    public let count: Int
    private let mapper: (UnsafePointer<RawValue>) -> Element

    fileprivate init(start: UnsafePointer<RawValue>, count: Int,
                     mapper: @escaping (UnsafePointer<RawValue>) -> Element) {
        data = start
        self.count = count
        self.mapper = mapper
    }

    fileprivate init(start: UnsafePointer<RawValue>, end: UnsafePointer<RawValue>,
                     mapper: @escaping (UnsafePointer<RawValue>) -> Element) {
        assert(end >= start)
        data = start
        count = end - start
        self.mapper = mapper
    }

    @_transparent
    public var startIndex: Int {
        0
    }

    @_transparent
    public var endIndex: Int {
        count
    }

    public subscript(position: Int) -> Element {
        mapper(data.advanced(by: position))
    }
}

extension ArrayRef where Element == RawValue {
    public init(start: UnsafePointer<Element>, count: Int) {
        self.init(start: start, count: count) { $0.pointee }
    }

    public init(start: UnsafePointer<Element>, end: UnsafePointer<Element>) {
        self.init(start: start, end: end) { $0.pointee }
    }
}

extension ArrayRef where Element: UnsafeRawRepresentable, Element.RawValue == RawValue {
    public init(start: UnsafePointer<RawValue>, count: Int) {
        self.init(start: start, count: count, mapper: Element.init(rawValue:))
    }

    public init(start: UnsafePointer<RawValue>, end: UnsafePointer<RawValue>) {
        self.init(start: start, end: end, mapper: Element.init(rawValue:))
    }
}
