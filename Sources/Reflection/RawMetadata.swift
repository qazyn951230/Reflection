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

/**
 ```c++
 // .../swift/include/swift/Basic/RelativePointer.h
 template <typename T, bool Nullable = true, typename Offset = int32_t, typename = void>
 class RelativeDirectPointer;

 /// A direct relative reference to an object that is not a function pointer.
 template <typename T, bool Nullable, typename Offset /* int32_t */ >
 class RelativeDirectPointer<T, Nullable, Offset> {
   Offset RelativeOffset;
 }

 // .../swift/include/swift/ABI/Metadata.h
 /// In-process native runtime target.
 struct InProcess {
   using StoredPointer = uintptr_t;
   using StoredSignedPointer = uintptr_t;

   template <typename T>
   using SignedPointer = T;

   template <typename T, bool Nullable = true>
   using RelativeDirectPointer = RelativeDirectPointer<T, Nullable>;
 }
 template <typename Runtime, typename T>
 using TargetSignedPointer = typename Runtime::template SignedPointer<T>;
 template <typename Runtime, typename Pointee, bool Nullable = true>
 using TargetRelativeDirectPointer = typename Runtime::template RelativeDirectPointer<Pointee, Nullable>;
 ```
 */
public protocol RawTargetMetadata {
    var kind: UInt { get }
}

public protocol TargetMetadata: UnsafeRawRepresentable where RawValue: RawTargetMetadata {
    var kind: Metadata.Kind { get }
}

extension TargetMetadata {
    public var kind: Metadata.Kind {
        Metadata.Kind.create(rawValue.pointee.kind)
    }

    public var isClass: Bool {
        kind == Metadata.Kind.class
    }

    public var isAnyClass: Bool {
        kind == .class || kind == .objCClassWrapper || kind == .foreignClass
    }

    public var isAnyExistentialType: Bool {
        kind == .existentialMetatype || kind == .existential
    }

    public static func load(from type: Any.Type) -> Self {
        Self(rawValue: unsafeBitCast(type, to: UnsafePointer<RawValue>.self))
    }
}

public protocol RawTargetValueMetadata: RawTargetMetadata {
    // const TargetValueTypeDescriptor<Runtime>* Description
    //   => TargetSignedPointer<Runtime, const TargetValueTypeDescriptor<Runtime>* > Description
    var description: UnsafeRawPointer { get }
}

public protocol TargetValueMetadata: TargetMetadata where RawValue: RawTargetValueMetadata {
    func asStructDescriptor() -> StructDescriptor
}

extension TargetValueMetadata {
    public func asStructDescriptor() -> StructDescriptor {
        StructDescriptor.cast(from: rawValue.pointee.description)
    }
}

// The common structure of all metadata for heap-allocated types.  A
// pointer to one of these can be retrieved by loading the 'isa'
// field of any heap object, whether it was managed by Swift or by
// Objective-C.  However, when loading from an Objective-C object,
// this metadata may not have the heap-metadata header, and it may
// not be the Swift type metadata for the object's dynamic type.
// public protocol TargetHeapMetadata: TargetMetadata {
// }

public protocol RawTargetAnyClassMetadata: RawTargetMetadata {
    var superclass: UnsafeRawPointer { get }
#if SWIFT_OBJC_INTEROP
    // TargetPointer<Runtime, void> CacheData[2];
    var cachedData1: UnsafeRawPointer { get }
    var cachedData2: UnsafeRawPointer { get }
    var data: UInt { get }
#endif
}

public protocol TargetAnyClassMetadata: TargetMetadata /* TargetHeapMetadata */
    where RawValue: RawTargetAnyClassMetadata {
    // Note that ObjC classes does not have a metadata header.

    /// The metadata for the superclass.  This is null for the root class.
    var superclass: UnsafeRawPointer { get }

    /// Is this object a valid swift type metadata?  That is, can it be
    /// safely downcast to ClassMetadata?
    func isTypeMetadata() -> Bool
    func isPureObjectiveC() -> Bool
}

extension TargetAnyClassMetadata {
    @_transparent
    public var superclass: UnsafeRawPointer {
        rawValue.pointee.superclass
    }

    public func isTypeMetadata() -> Bool {
        true
    }

    public func isPureObjectiveC() -> Bool {
        !isTypeMetadata()
    }
}

// public struct TargetValueWitnessFlags: OptionSet {
//    public var rawValue: Int
//
//    public init(rawValue: Int) {
//        self.rawValue = rawValue
//    }
//
//    public static let alignmentMask = TargetValueWitnessFlags(rawValue: 0x000000FF)
//    public static let nonPOD = TargetValueWitnessFlags(rawValue: 0x00010000)
//    public static let nonInline = TargetValueWitnessFlags(rawValue: 0x00020000)
//    public static let hasSpareBits = TargetValueWitnessFlags(rawValue: 0x00080000)
//    public static let nonBitwiseTakable = TargetValueWitnessFlags(rawValue: 0x00100000)
//    public static let hasEnumWitnesses = TargetValueWitnessFlags(rawValue: 0x00200000)
//    public static let incomplete = TargetValueWitnessFlags(rawValue: 0x00400000)
// }
//
// public struct TargetValueWitnessTable {
//    /// The required storage size of a single object of this type.
//    let size: Int // size_t?
//    /// The required size per element of an array of this type. It is at least
//    /// one, even for zero-sized types, like the empty tuple.
//    let stride: Int // size_t?
//    /// The ValueWitnessAlignmentMask bits represent the required
//    /// alignment of the first byte of an object of this type, expressed
//    /// as a mask of the low bits that must not be set in the pointer.
//    /// This representation can be easily converted to the 'alignof'
//    /// result by merely adding 1, but it is more directly useful for
//    /// performing dynamic structure layouts, and it grants an
//    /// additional bit of precision in a compact field without needing
//    /// to switch to an exponent representation.
//    ///
//    /// The ValueWitnessIsNonPOD bit is set if the type is not POD.
//    ///
//    /// The ValueWitnessIsNonInline bit is set if the type cannot be
//    /// represented in a fixed-size buffer or if it is not bitwise takable.
//    ///
//    /// The ExtraInhabitantsMask bits represent the number of "extra inhabitants"
//    /// of the bit representation of the value that do not form valid values of
//    /// the type.
//    ///
//    /// The Enum_HasSpareBits bit is set if the type's binary representation
//    /// has unused bits.
//    ///
//    /// The HasEnumWitnesses bit is set if the type is an enum type.
//    let flags: Int /* TargetValueWitnessFlags */
//    /// The number of extra inhabitants in the type.
//    let extraInhabitantCount: UInt32
// }
//
// public struct TargetTypeMetadataHeader {
//    public let valueWitnesses: UnsafePointer<TargetValueWitnessTable>
// }
