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

// .../swift/include/swift/ABI/Metadata.h!TargetStructDescriptor

public struct StructDescriptor: TargetTypeContextDescriptor, TrailingGenericContainer {
    public typealias Header = TypeGenericContextDescriptorHeader

    public let rawValue: UnsafePointer<RawValue>

    public init(rawValue: UnsafePointer<RawValue>) {
        self.rawValue = rawValue
    }

    public var parent: ContextDescriptor? {
        guard let address = RelativeIndirectablePointer.resolve(any: rawValue, keyPath: \RawValue.parent) else {
            return nil
        }
        return ContextDescriptor.cast(from: address)
    }

    var cName: UnsafePointer<Int8> {
        RelativeDirectPointer.resolve(rawValue, keyPath: \RawValue.name)
            .reinterpretCast(to: Int8.self)
    }

    public var name: String {
        return String(cString: cName)
    }

    public var fields: FieldDescriptor? {
        let raw = RelativeDirectPointer.resolve(any: rawValue, keyPath: \RawValue.fields)
        return (raw?.reinterpretCast(to: FieldDescriptor.RawValue.self))
            .map(FieldDescriptor.init(rawValue:))
    }

    /// The number of stored properties in the struct.
    /// If there is a field offset vector, this is its length.
    @_transparent
    public var fieldCount: UInt32 {
        rawValue.pointee.fieldCount
    }

    /// The offset of the field offset vector for this struct's stored
    /// properties in its metadata, if any. 0 means there is no field offset
    /// vector.
    @_transparent
    public var fieldOffsetVectorOffset: UInt32 {
        rawValue.pointee.fieldOffsetVectorOffset
    }

    /// True if metadata records for this type have a field offset vector for
    /// its stored properties.
    func hasFieldOffsetVector() -> Bool {
        fieldOffsetVectorOffset != 0
    }

    public struct RawValue: RawTargetTypeContextDescriptor {
        public let flags: UInt32
        public let parent: Int32
        public let name: Int32
        public let accessFunction: Int32
        public let fields: Int32
        public let fieldCount: UInt32 // NumFields
        public let fieldOffsetVectorOffset: UInt32
    }

    @inlinable
    public static func genericArgumentOffset() -> Int? {
        StructMetadata.genericArgumentOffset()
    }
}
