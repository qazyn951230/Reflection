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

extension Metadata {
    // .../swift/include/swift/ABI/MetadataValues.h
    // .../swift/include/swift/ABI/MetadataKind.def
    public enum Kind: UInt32 { // MetadataKind
        /// A class type.
        case `class` = 0
        /// A struct type.
        case `struct` = 0x200
        /// An enum type.
        /// If we add reference enums, that needs to go here.
        case `enum` = 0x201
        /// An optional type.
        case optional = 0x202
        /// A foreign class, such as a Core Foundation class.
        case foreignClass = 0x203
        /// A type whose value is not exposed in the metadata system.
        case opaque = 0x300
        /// A tuple.
        case tuple = 0x301
        /// A monomorphic function.
        case function = 0x302
        /// An existential type.
        case existential = 0x303
        /// A metatype.
        case metatype = 0x304
        /// An ObjC class wrapper.
        case objCClassWrapper = 0x305
        /// An existential metatype.
        case existentialMetatype = 0x306
        /// A heap-allocated local variable using statically-generated metadata.
        case heapLocalVariable = 0x400
        /// A heap-allocated local variable using runtime-instantiated metadata.
        case heapGenericLocalVariable = 0x500
        /// A native error object.
        case errorObject = 0x501

        @inlinable
        @inline(__always)
        public static func create(_ value: UInt32) -> Kind {
            Kind(rawValue: value) ?? .class
        }

        @inlinable
        @inline(__always)
        public static func create(_ value: UInt) -> Kind {
            Metadata.Kind.create(UInt32(truncatingIfNeeded: value))
        }
    }

    /// Non-type metadata kinds have this bit set.
    public static let nonTypeKindMask: UInt32 = 0x400

    /// Non-heap metadata kinds have this bit set.
    public static let nonHeapKindMask: UInt32 = 0x200

    // The above two flags are negative because the "class" kind has to be zero,
    // and class metadata is both type and heap metadata.

    /// Runtime-private metadata has this bit set. The compiler must not statically
    /// generate metadata objects with these kinds, and external tools should not
    /// rely on the stability of these values or the precise binary layout of
    /// their associated data structures.
    public static let runtimePrivateKindMask: UInt32 = 0x100
}
