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

// .../swift/include/swift/ABI/Metadata.h!TargetProtocolDescriptor

/// A protocol descriptor.
///
/// Protocol descriptors contain information about the contents of a protocol:
/// it's name, requirements, requirement signature, context, and so on. They
/// are used both to identify a protocol and to reason about its contents.
///
/// Only Swift protocols are defined by a protocol descriptor, whereas
/// Objective-C (including protocols defined in Swift as @objc) use the
/// Objective-C protocol layout.
struct ProtocolDescriptor: TargetContextDescriptor, TrailingGenericContainer {
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

    /// The name of the protocol.
    public var name: String {
        return String(cString: cName)
    }

    /// The number of generic requirements in the requirement signature of the
    /// protocol.
    @_transparent
    public var requirementsInSignatureCount: UInt32 {
        rawValue.pointee.requirementsInSignatureCount
    }

    /// The number of requirements in the protocol.
    /// If any requirements beyond MinimumWitnessTableSizeInWords are present
    /// in the witness table template, they will be not be overwritten with
    /// defaults.
    @_transparent
    public var requirementsCount: UInt32 {
        rawValue.pointee.requirementsCount
    }

    public func protocolContextDescriptorFlags() -> ProtocolContextDescriptorFlags {
        ProtocolContextDescriptorFlags(rawValue: flags.kindSpecificFlags)
    }

    /// Retrieve the requirements that make up the requirement signature of
    /// this protocol.
    public func requirementSignature() -> ArrayRef<GenericRequirementDescriptor, GenericRequirementDescriptor> {
        ArrayRef(start: trailingObjects(as: GenericRequirementDescriptor.self),
                 count: Int(requirementsInSignatureCount))
    }

    /// Retrieve the requirements of this protocol.
    public func requirements() -> ArrayRef<ProtocolRequirement, ProtocolRequirement> {
        ArrayRef(start: trailingObjects(as: ProtocolRequirement.self),
                 count: Int(requirementsCount))
    }

    public struct RawValue: RawTargetContextDescriptor {
        public let flags: UInt32
        public let parent: Int32
        // TargetRelativeDirectPointer<Runtime, const char, /*nullable*/ false> Name;
        public let name: Int32
        public let requirementsInSignatureCount: UInt32 // NumRequirementsInSignature
        public let requirementsCount: UInt32 // NumRequirements
        // RelativeDirectPointer<const char, /*Nullable=*/true> AssociatedTypeNames;
        public let associatedTypeNames: Int32
    }

    static var followingTrailingTypes: [AnyLayout] {
        [AnyLayout(GenericRequirementDescriptor.self), AnyLayout(ProtocolRequirement.self)]
    }

    func followingTrailingObjectsCount(of layout: AnyLayout) -> UInt {
        switch layout {
        case GenericRequirementDescriptor.self:
            return UInt(requirementsInSignatureCount)
        case ProtocolRequirement.self:
            return UInt(requirementsCount)
        default:
            return 0
        }
    }
}

/// A protocol requirement descriptor. This describes a single protocol
/// requirement in a protocol descriptor. The index of the requirement in
/// the descriptor determines the offset of the witness in a witness table
/// for this protocol.
public struct ProtocolRequirement { // TargetProtocolRequirement
    public let flags: ProtocolRequirementFlags
    // TODO: name, type

    /// The optional default implementation of the protocol.
    public let defaultImplementation: Int32
    // RelativeDirectPointer<void, /*nullable*/ true> DefaultImplementation;
}

public enum ProtocolRequirementKind: UInt32 {
    case baseProtocol
    case method
    case `init`
    case getter
    case setter
    case readCoroutine
    case modifyCoroutine
    case associatedTypeAccessFunction
    case associatedConformanceAccessFunction
}

/// Flags that go in a ProtocolRequirement structure.
public struct ProtocolRequirementFlags: OptionSet {
    public typealias RawValue = UInt32

    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    /// Is the method an instance member?
    ///
    /// Note that `init` is not considered an instance member.
    public var isInstance: Bool {
        contains(.isInstanceMask)
    }

    public var kind: ProtocolRequirementKind {
        ProtocolRequirementKind(rawValue: union(.kindMask).rawValue) ??
            ProtocolRequirementKind.baseProtocol
    }

    private static let kindMask = ProtocolRequirementFlags(rawValue: 0x0F)
    private static let isInstanceMask = ProtocolRequirementFlags(rawValue: 0x10)
}

public struct ProtocolContextDescriptorFlags: FlagSet {
    public typealias RawValue = UInt16

    public var rawValue: UInt16

    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    public var hasClassConstraint: Bool {
        readBit(offset: ProtocolContextDescriptorFlags.hasClassConstraintOffset)
    }

    public var isResilient: Bool {
        readBit(offset: ProtocolContextDescriptorFlags.isResilientOffset)
    }

    public var specialProtocol: SpecialProtocol {
        let value: UInt8 = readBit(offset: ProtocolContextDescriptorFlags.specialProtocolKindOffset,
                                   width: ProtocolContextDescriptorFlags.specialProtocolKindWidth)
        return SpecialProtocol(rawValue: value) ?? SpecialProtocol.none
    }

    @inline(__always)
    private static let hasClassConstraintOffset: UInt32 = 0

    @inline(__always)
    private static let isResilientOffset: UInt32 = 1

    @inline(__always)
    private static let specialProtocolKindOffset: UInt32 = 2
    @inline(__always)
    private static let specialProtocolKindWidth: UInt32 = 6
}

/// Identifiers for protocols with special meaning to the Swift runtime.
public enum SpecialProtocol: UInt8 {
    /// Not a special protocol.
    ///
    /// This must be 0 for ABI compatibility with Objective-C protocol_t records.
    case none = 0
    /// The Error protocol.
    case error = 1
}
