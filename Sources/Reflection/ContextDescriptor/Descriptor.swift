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

// .../swift/include/swift/ABI/Metadata.h!TargetContextDescriptor

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

    public func tree() -> [ContextDescriptor] {
        var current: ContextDescriptor? = self
        var result: [ContextDescriptor] = []
        while let t = current {
            result.append(t)
            current = t.parent
        }
        return result
    }

    public func genericContext() -> GenericContext? {
        guard isGeneric else {
            return nil
        }
        switch kind {
        case .extension:
            return self.as(ExtensionContextDescriptor.self)
                .genericContext()
        case .anonymous:
            return self.as(ExtensionContextDescriptor.self)
                .genericContext()
        case .class:
            return self.as(ClassDescriptor.self)
                .genericContext()
        case .enum:
            return self.as(EnumDescriptor.self)
                .genericContext()
        case .struct:
            return self.as(StructDescriptor.self)
                .genericContext()
        case .opaqueType:
            return self.as(ExtensionContextDescriptor.self)
                .genericContext()
        case .module:
            // Never generic.
            fallthrough
        default:
            return nil
        }
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
}
