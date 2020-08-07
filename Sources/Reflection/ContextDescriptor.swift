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

/// Flags for nominal type context descriptors. These values are used as the
/// kindSpecificFlags of the ContextDescriptorFlags for the type.
public struct TypeContextDescriptorKind: OptionSet { // TypeContextDescriptorFlags
    public var rawValue: UInt16

    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    /// Whether there's something unusual about how the metadata is
    /// initialized.
    ///
    /// Meaningful for all type-descriptor kinds.
    public static let initialization: TypeContextDescriptorKind = []
}

struct ContextDescriptor {
    static func rawFields<T>(_ value: T) -> UnsafePointer<FieldDescriptor.RawValue>?
        where T: TargetTypeContextDescriptor {
        let fields = value.rawValue.pointee.fields
        guard fields != 0 else {
            return nil
        }
//        MemoryLayout.offset(of: \T.RawValue.fields) == nil
        let offset = MemoryLayout<Int32>.size * 4
        return value.rawValue.reinterpretCast(to: Int8.self)
            .advanced(by: offset + Int(fields))
            .reinterpretCast(to: FieldDescriptor.RawValue.self)
    }
}

// template <typename Runtime> class TargetStructDescriptor
public struct StructDescriptor: TargetTypeContextDescriptor {
    public let rawValue: UnsafePointer<RawValue>

    public init(rawValue: UnsafePointer<RawValue>) {
        self.rawValue = rawValue
    }

    public var name: String? {
        let name = rawValue.pointee.name
        guard name != 0, let offset = MemoryLayout.offset(of: \RawValue.name) else {
            return nil
        }
        let c = rawValue.reinterpretCast(to: Int8.self)
            .advanced(by: offset + Int(name))
        return String(cString: c)
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
        public let kind: UInt32
        public let parent: UInt32
        public let name: Int32
        public let accessFunction: Int32
        public let fields: Int32
        public let fieldCount: UInt32 // NumFields
        public let fieldOffsetVectorOffset: UInt32
    }
}

// template <typename Runtime> class TargetEnumDescriptor
public struct EnumDescriptor: TargetTypeContextDescriptor {
    public let rawValue: UnsafePointer<RawValue>

    public init(rawValue: UnsafePointer<RawValue>) {
        self.rawValue = rawValue
    }

    public var name: String? {
        let name = rawValue.pointee.name
        guard name != 0, let offset = MemoryLayout.offset(of: \RawValue.name) else {
            return nil
        }
        let c = rawValue.reinterpretCast(to: Int8.self)
            .advanced(by: offset + Int(name))
        return String(cString: c)
    }

    public var payloadCasesCount: UInt32 {
        let value = rawValue.pointee.payloadCasesCountAndPayloadSizeOffset
        return value & UInt32(0x00FF_FFFF)
    }

    /// The number of empty cases in the enum.
    @_transparent
    public var emptyCasesCount: UInt32 {
        rawValue.pointee.emptyCasesCount
    }

    public var payloadSizeOffset: Int {
        let value = rawValue.pointee.payloadCasesCountAndPayloadSizeOffset
        return Int((value & UInt32(0xFF00_0000)) >> UInt32(24))
    }

    public var hasPayloadSizeOffset: Bool {
        payloadSizeOffset != 0
    }

    public struct RawValue: RawTargetTypeContextDescriptor {
        public let kind: UInt32
        public let parent: UInt32
        public let name: Int32
        public let accessFunction: Int32
        public let fields: Int32
        /// The number of non-empty cases in the enum are in the low 24 bits;
        /// the offset of the payload size in the metadata record in words,
        /// if any, is stored in the high 8 bits.
        public let payloadCasesCountAndPayloadSizeOffset: UInt32
        public let emptyCasesCount: UInt32
    }
}
