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

public struct Metadata: TargetMetadata {
    public let rawValue: UnsafePointer<RawValue>

    public init(rawValue: UnsafePointer<RawValue>) {
        self.rawValue = rawValue
    }

    public var isValueMetadata: Bool {
        let value = UInt32(truncatingIfNeeded: rawValue.pointee.kind)
        return value == Metadata.Kind.struct.rawValue || value == Metadata.Kind.enum.rawValue
    }

    public var isStructMetadata: Bool {
        let value = UInt32(truncatingIfNeeded: rawValue.pointee.kind)
        return value == Metadata.Kind.struct.rawValue
    }

    public var isEnumMetadata: Bool {
        let value = UInt32(truncatingIfNeeded: rawValue.pointee.kind)
        return value == Metadata.Kind.enum.rawValue
    }
    
    public func `as`<T>(type: T.Type) -> T where T: TargetMetadata {
        T.cast(from: rawValue)
    }

    public struct RawValue: RawTargetMetadata {
        public let kind: UInt
    }

    public static func load<T>(from type: Any.Type, as target: Metadata.Type)
        -> T? where T: TargetMetadata {
        let kind = readKind(from: type)
        switch kind {
        case .struct:
            return StructMetadata.load(from: type) as? T
        case .enum:
            return EnumMetadata.load(from: type) as? T
        default:
            return nil
        }
    }

    public static func readKind(from type: Any.Type) -> Kind {
        let raw = unsafeBitCast(type, to: UnsafePointer<UInt>.self)
        return Metadata.Kind.create(raw.pointee)
    }
}

extension Metadata {
    public func dump() {
        print("Metadata.")
        print("Kind: \(kind).")
    }

    /**
     ```swift
     @_silgen_name("swift_getTypeByMangledNameInContext")
     public func _getTypeByMangledNameInContext(
       _ name: UnsafePointer<UInt8>,
       _ nameLength: UInt,
       genericContext: UnsafeRawPointer?,
       genericArguments: UnsafeRawPointer?)
       -> Any.Type?
     ```
     ```c++
     const Metadata * _Nullable
     swift_getTypeByMangledNameInContext(
                             const char *typeNameStart,
                             size_t typeNameLength,
                             const TargetContextDescriptor<InProcess> *context,
                             const void * const *genericArgs) {
     ```
     */
    @_transparent
    static func resolveType(by mangledName: UnsafePointer<UInt8>, nameLength: UInt,
                            context: UnsafeRawPointer?, arguments: UnsafeRawPointer?) -> Any.Type? {
        Swift._getTypeByMangledNameInContext(mangledName, nameLength,
                                             genericContext: context, genericArguments: arguments)
    }

    static func resolveType(by mangledName: UnsafePointer<UInt8>, context: UnsafeRawPointer?,
                            arguments: UnsafeRawPointer?) -> Any.Type? {
        resolveType(by: mangledName, nameLength: mangledNameLength(mangledName),
                    context: context, arguments: arguments)
    }

    static func mangledNameLength(_ start: UnsafePointer<UInt8>) -> UInt {
        var end = start
        var current = end.pointee
        while current != 0 {
            if current >= 0x01 && current <= 0x17 {
                end += MemoryLayout<UInt32>.size
            } else if current >= 0x18 && current <= 0x1F {
                end += MemoryLayout<UInt>.size
            }
            end += 1
            current = end.pointee
        }
        return UInt(end.distance(to: start))
    }
}

/// The common structure of metadata for structs and enums.
public struct ValueMetadata: TargetValueMetadata {
    public let rawValue: UnsafePointer<RawValue>

    public init(rawValue: UnsafePointer<RawValue>) {
        self.rawValue = rawValue
    }

    public struct RawValue: RawTargetValueMetadata {
        public let kind: UInt // From Metadata
        public let description: UnsafeRawPointer
    }
}

/// The structure of type metadata for structs.
public struct StructMetadata: TargetValueMetadata { // TargetStructMetadata
    public typealias RawValue = ValueMetadata.RawValue

    public let rawValue: UnsafePointer<RawValue>
    public let description: StructDescriptor

    public init(rawValue: UnsafePointer<RawValue>) {
        self.rawValue = rawValue
        description = StructDescriptor.cast(from: rawValue.pointee.description)
    }

    // The first trailing field of struct metadata is always the generic
    // argument array.

    /// Get a pointer to the field offset vector, if present, or null.
    var fieldOffsets: UnsafePointer<UInt32>? {
        let offset = description.fieldOffsetVectorOffset
        if offset == 0 {
            return nil
        }
        return rawValue.reinterpretCast(to: UInt8.self)
            .advanced(by: Int(offset))
            .reinterpretCast(to: UInt32.self)
    }

    public func fieldOffset(at index: Int) -> Int? {
        guard let list = fieldOffsets, index < description.fieldCount else {
            return nil
        }
        return Int(list.advanced(by: index).pointee)
    }

    @_transparent
    public var isReflectable: Bool {
        description.isReflectable
    }
}

/// The structure of type metadata for enums.
public struct EnumMetadata: TargetValueMetadata { // TargetStructMetadata
    public typealias RawValue = ValueMetadata.RawValue

    public let rawValue: UnsafePointer<RawValue>
    public let description: EnumDescriptor

    public init(rawValue: UnsafePointer<RawValue>) {
        self.rawValue = rawValue
        description = EnumDescriptor.cast(from: rawValue.pointee.description)
    }
}
