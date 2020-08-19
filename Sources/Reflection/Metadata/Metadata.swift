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

    public init<T>(other: T) where T: TargetMetadata {
        self = Metadata.cast(from: other.rawValue)
    }

    public func cast<T>() -> T where T: TargetMetadata {
        T.cast(from: rawValue)
    }

    public func `as`<T>(_ type: T.Type) -> T where T: TargetMetadata {
        T.cast(from: rawValue)
    }

    public struct RawValue: RawTargetMetadata {
        public let kind: UInt
    }

    public static func load<T>(from type: Any.Type, as target: T.Type)
        -> T? where T: TargetMetadata {
        let kind = readKind(from: type)
        switch kind {
        case .class:
            return ClassMetadata.load(from: type) as? T
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

extension Metadata: Equatable {
    public static func == (lhs: Metadata, rhs: Metadata) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    public static func == <T>(lhs: Metadata, rhs: T.Type) -> Bool {
        lhs.rawValue == unsafeBitCast(rhs as Any.Type, to: UnsafePointer<Metadata.RawValue>.self)
    }

    public static func == <T>(lhs: T.Type, rhs: Metadata) -> Bool {
        unsafeBitCast(lhs as Any.Type, to: UnsafePointer<Metadata.RawValue>.self) == rhs.rawValue
    }

    public static func == (lhs: Metadata, rhs: Any.Type) -> Bool {
        lhs.rawValue == unsafeBitCast(rhs, to: UnsafePointer<Metadata.RawValue>.self)
    }

    public static func == (lhs: Any.Type, rhs: Metadata) -> Bool {
        unsafeBitCast(lhs, to: UnsafePointer<Metadata.RawValue>.self) == rhs.rawValue
    }

    public static func == (lhs: Metadata, rhs: AnyLayout) -> Bool {
        lhs.rawValue == rhs._metadata
    }

    public static func == (lhs: AnyLayout, rhs: Metadata) -> Bool {
        lhs._metadata == rhs.rawValue
    }

    public static func ~= <T>(pattern: T.Type, value: Metadata) -> Bool {
        value.rawValue == unsafeBitCast(pattern as Any.Type, to: UnsafePointer<Metadata.RawValue>.self)
    }

    public static func ~= (pattern: Any.Type, value: Metadata) -> Bool {
        value.rawValue == unsafeBitCast(pattern, to: UnsafePointer<Metadata.RawValue>.self)
    }

    public static func ~= (pattern: AnyLayout, value: Metadata) -> Bool {
        value.rawValue == pattern._metadata
    }
}

extension Metadata {
//    public func dump() {
//        print("Metadata.")
//        print("Kind: \(kind).")
//    }

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
                             const void * const *genericArgs);
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

    // .../swift/stdlib/public/core/KeyPath.swift!_getSymbolicMangledNameLength
    static func mangledNameLength(_ start: UnsafePointer<UInt8>) -> UInt {
        var end = start
        var current = end.pointee
        while current != 0 {
            // Skip the current character
            end += 1
            if current >= 0x01 && current <= 0x17 {
                end += MemoryLayout<UInt32>.size
            } else if current >= 0x18 && current <= 0x1F {
                end += MemoryLayout<UInt>.size
            }
            end += 1
            current = end.pointee
        }
        return UInt(start.distance(to: end))
    }
}
