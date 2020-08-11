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

public enum MetadataInitializationKind: UInt16 {
    case none = 0
    case single = 1
    case foreign = 2
}

/// Kinds of type metadata/protocol conformance records.
public enum TypeReferenceKind: UInt32 {
    /// The conformance is for a nominal type referenced directly;
    /// getTypeDescriptor() points to the type context descriptor.
    case directTypeDescriptor = 0x00
    /// The conformance is for a nominal type referenced indirectly;
    /// getTypeDescriptor() points to the type context descriptor.
    case indirectTypeDescriptor = 0x01
    /// The conformance is for an Objective-C class that should be looked up
    /// by class name.
    case directObjCClassName = 0x02
    /// The conformance is for an Objective-C class that has no nominal type
    /// descriptor.
    /// getIndirectObjCClass() points to a variable that contains the pointer to
    /// the class object, which then requires a runtime call to get metadata.
    ///
    /// On platforms without Objective-C interoperability, this case is
    /// unused.
    case indirectObjCClass = 0x03
}

/// Flags for nominal type context descriptors. These values are used as the
/// kindSpecificFlags of the ContextDescriptorFlags for the type.
public struct TypeContextDescriptorFlags: FlagSet {
    public typealias RawValue = UInt16

    public var rawValue: UInt16

    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    public var metadataInitialization: MetadataInitializationKind {
        let value: UInt16 = readBit(offset: TypeContextDescriptorFlags.metadataInitializationOffset,
            width: TypeContextDescriptorFlags.metadataInitializationWidth)
        return MetadataInitializationKind(rawValue: value) ?? MetadataInitializationKind.none
    }

    public var hasImportInfo: Bool {
        readBit(offset: TypeContextDescriptorFlags.hasImportInfoOffset)
    }

    public var classHasVTable: Bool {
        readBit(offset: TypeContextDescriptorFlags.classHasVTableOffset)
    }

    public var classHasOverrideTable: Bool {
        readBit(offset: TypeContextDescriptorFlags.classHasOverrideTableOffset)
    }

    public var classHasResilientSuperclass: Bool {
        readBit(offset: TypeContextDescriptorFlags.classHasResilientSuperclassOffset)
    }

    public var classAreImmediateMembersNegative: Bool {
        readBit(offset: TypeContextDescriptorFlags.classAreImmediateMembersNegativeOffset)
    }

    public var classResilientSuperclassReferenceKind: TypeReferenceKind {
        let value: UInt32 = readBit(offset: TypeContextDescriptorFlags.classResilientSuperclassReferenceKindOffset,
            width: TypeContextDescriptorFlags.classResilientSuperclassReferenceKindWidth)
        return TypeReferenceKind(rawValue: value) ?? TypeReferenceKind.directTypeDescriptor
    }

    @inline(__always)
    private static let metadataInitializationOffset: UInt32 = 0
    @inline(__always)
    private static let metadataInitializationWidth: UInt32 = 2
    @inline(__always)
    private static let hasImportInfoOffset: UInt32 = 2
    @inline(__always)
    private static let classResilientSuperclassReferenceKindOffset: UInt32 = 9
    @inline(__always)
    private static let classResilientSuperclassReferenceKindWidth: UInt32 = 3
    @inline(__always)
    private static let classAreImmediateMembersNegativeOffset: UInt32 = 12
    @inline(__always)
    private static let classHasResilientSuperclassOffset: UInt32 = 13
    @inline(__always)
    private static let classHasOverrideTableOffset: UInt32 = 14
    @inline(__always)
    private static let classHasVTableOffset: UInt32 = 15
}
