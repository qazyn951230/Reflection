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

public protocol Reflected {
    var type: Any.Type { get }
}

public struct ReflectedElement: Reflected {
    public let type: Any.Type
    public let value: Any
}

public protocol ReflectedProperty: Reflected {
    var name: String { get }
    var offset: UInt32 { get }
    
    func copy<T>(from value: T) -> Any
}

struct StructProperty: ReflectedProperty {
    public let offset: UInt32
    public let type: Any.Type
    public let name: String
    let metadata: UnsafePointer<StructMetadata.RawValue>
    let mangledTypeName: UnsafePointer<Int8>

    init(metadata: StructMetadata, name: String, mangledTypeName: UnsafePointer<Int8>,
         offset: UInt32, type: Any.Type) {
        self.metadata = metadata.rawValue
        self.name = name
        self.mangledTypeName = mangledTypeName
        self.offset = offset
        self.type = type
    }

    @_transparent
    func copy<T>(from value: T) -> Any {
        copyStructField(metadata: metadata, name: mangledTypeName, fieldOffset: offset, value: value)
    }
}
