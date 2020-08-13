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

public struct ContextDescriptor: TargetContextDescriptor {
    public let rawValue: UnsafePointer<RawValue>

    public init(rawValue: UnsafePointer<RawValue>) {
        self.rawValue = rawValue
    }

    public init<T>(other: T) where T: TargetContextDescriptor {
        self = ContextDescriptor.cast(from: other.rawValue)
    }

    public var parent: ContextDescriptor? {
        guard let address = RelativeIndirectablePointer.resolve(any: rawValue, keyPath: \RawValue.parent) else {
            return nil
        }
        return ContextDescriptor.cast(from: address)
    }

    public func `as`<T>(_ type: T.Type) -> T where T: TargetContextDescriptor {
        T.cast(from: rawValue)
    }

    public struct RawValue: RawTargetContextDescriptor {
        public let flags: UInt32
        public let parent: Int32
    }

    public static func create<T>(_ value: UnsafeRawPointer, as type: T.Type)
        -> T? where T: TargetContextDescriptor {
        let flags = value.reinterpretCast(to: UInt32.self).pointee
        let kind = ContextDescriptorFlags(rawValue: flags).kind
        switch kind {
        case .struct:
            return StructDescriptor.cast(from: value) as? T
        case .enum:
            return EnumDescriptor.cast(from: value) as? T
        case .module:
            return ModuleContextDescriptor.cast(from: value) as? T
        default:
            return ContextDescriptor.cast(from: value) as? T
        }
    }

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

    @inlinable
    public static func genericArgumentOffset() -> Int {
        fatalError("Not a generic context descriptor")
    }
}

/// Descriptor for a module context.
public struct ModuleContextDescriptor: TargetContextDescriptor { // TargetModuleContextDescriptor
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

    public var name: String {
        let c = RelativeDirectPointer.resolve(rawValue, keyPath: \RawValue.name)
            .reinterpretCast(to: Int8.self)
        return String(cString: c)
    }

    public struct RawValue: RawTargetContextDescriptor {
        public let flags: UInt32
        public let parent: Int32
        // RelativeDirectPointer<const char, /*nullable*/ false> Name;
        public let name: Int32
    }

    @inlinable
    public static func genericArgumentOffset() -> Int {
        fatalError("Not a generic context descriptor")
    }
}

public struct ClassDescriptor: TargetTypeContextDescriptor { // TargetClassDescriptor
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

    public var name: String {
        let c = RelativeDirectPointer.resolve(rawValue, keyPath: \RawValue.name)
            .reinterpretCast(to: Int8.self)
        return String(cString: c)
    }

    public struct RawValue: RawTargetTypeContextDescriptor {
        public let flags: UInt32
        public let parent: Int32
        public let name: Int32
        public let accessFunction: Int32
        public let fields: Int32
        // TargetRelativeDirectPointer<Runtime, const char> SuperclassType;
        public let superclassType: Int32
        /// ```c++
        /// union {
        ///     uint32_t MetadataNegativeSizeInWords;
        ///     TargetRelativeDirectPointer<Runtime, TargetStoredClassMetadataBounds<Runtime>>
        ///         ResilientMetadataBounds;
        /// }
        /// ```
        public let resilientMetadataBounds: UInt32
        /// ```c++
        /// union {
        ///     uint32_t MetadataPositiveSizeInWords;
        ///     ExtraClassDescriptorFlags ExtraClassFlags;
        /// }
        /// ```
        public let extraClassFlags: UInt32
        public let immediateMembersCount: UInt32
        public let fieldsCount: UInt32
        public let fieldOffsetVectorOffset: UInt32
    }

    @inlinable
    public static func genericArgumentOffset() -> Int {
        fatalError("Not a generic context descriptor")
    }
}

// TargetStructDescriptor
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

    public var name: String {
        let c = RelativeDirectPointer.resolve(rawValue, keyPath: \RawValue.name)
            .reinterpretCast(to: Int8.self)
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
        public let flags: UInt32
        public let parent: Int32
        public let name: Int32
        public let accessFunction: Int32
        public let fields: Int32
        public let fieldCount: UInt32 // NumFields
        public let fieldOffsetVectorOffset: UInt32
    }

    @inlinable
    public static func genericArgumentOffset() -> Int {
        StructMetadata.genericArgumentOffset()
    }
}

public struct EnumDescriptor: TargetTypeContextDescriptor { // TargetEnumDescriptor
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

    public var name: String {
        let c = RelativeDirectPointer.resolve(rawValue, keyPath: \RawValue.name)
            .reinterpretCast(to: Int8.self)
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
        public let flags: UInt32
        public let parent: Int32
        public let name: Int32
        public let accessFunction: Int32
        public let fields: Int32
        /// The number of non-empty cases in the enum are in the low 24 bits;
        /// the offset of the payload size in the metadata record in words,
        /// if any, is stored in the high 8 bits.
        public let payloadCasesCountAndPayloadSizeOffset: UInt32
        public let emptyCasesCount: UInt32
    }

    @inlinable
    public static func genericArgumentOffset() -> Int {
        fatalError("Not a generic context descriptor")
    }
}
