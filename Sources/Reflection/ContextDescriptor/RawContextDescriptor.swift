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

public protocol RawTargetContextDescriptor {
    /// Flags describing the context, including its kind and format version.
    var flags: UInt32 { get }
    /// The parent context, or null if this is a top-level context.
    var parent: Int32 { get }
    // RelativeContextPointer<Runtime> Parent
    // => template<typename Runtime> using RelativeContextPointer =
    //      RelativeIndirectablePointer<const TargetContextDescriptor<Runtime>, /*nullable*/ true>;
}

public protocol TargetContextDescriptor: UnsafeRawRepresentable where RawValue: RawTargetContextDescriptor {
    var kind: ContextDescriptorKind { get }
    var parent: ContextDescriptor? { get }

    static func genericArgumentOffset() -> Int
}

extension TargetContextDescriptor {
    public var flags: ContextDescriptorFlags {
        ContextDescriptorFlags(rawValue: rawValue.pointee.flags)
    }

    public var kind: ContextDescriptorKind {
        flags.kind
    }

    @_transparent
    public var isGeneric: Bool {
        flags.isGeneric
    }

    @_transparent
    public var isUnique: Bool {
        flags.isUnique
    }
}

extension TargetContextDescriptor where Self: TrailingGenericContainer {
    public func genericContext() -> GenericContext? {
        guard isGeneric else {
            return nil
        }
        // Header address = UInt(bitPattern: header + 1) - UInt(MemoryLayout<GenericContextDescriptorHeader>.size
        let header = trailingObjects(as: Self.Header.self)
        let raw = UnsafeRawPointer(bitPattern: UInt(bitPattern: header + 1) -
            UInt(MemoryLayout<GenericContextDescriptorHeader>.size + MemoryLayout<GenericContext.RawValue>.size)
        ).unsafelyUnwrapped
        return GenericContext.cast(from: raw)
    }

    public func genericParameters() -> ArrayRef<GenericParamDescriptor, GenericParamDescriptor>? {
        guard isGeneric else {
            return nil
        }
        let start = trailingObjects(as: GenericParamDescriptor.self)
        let count = genericContextHeader().parametersCount
        return ArrayRef(start: start, count: Int(count))
    }

    public func genericArguments(of metadata: Metadata) -> UnsafePointer<UnsafePointer<Metadata.RawValue>> {
        let raw = metadata.rawValue.reinterpretCast(to: UnsafePointer<Metadata.RawValue>.self)
        return raw + Self.genericArgumentOffset()
    }

    public func genericArguments<T>(metadata: T) -> UnsafePointer<UnsafePointer<Metadata.RawValue>>
        where T: TargetMetadata {
        let raw = metadata.rawValue.reinterpretCast(to: UnsafePointer<Metadata.RawValue>.self)
        return raw + Self.genericArgumentOffset()
    }

    public func genericArguments(of metadata: AnyMetadata) -> UnsafePointer<UnsafePointer<Metadata.RawValue>> {
        let raw = metadata.rawValue.reinterpretCast(to: UnsafePointer<Metadata.RawValue>.self)
        return raw + Self.genericArgumentOffset()
    }
}

public protocol RawTargetTypeContextDescriptor: RawTargetContextDescriptor {
    // TargetRelativeDirectPointer<Runtime, const char, /*nullable*/ false> Name;
    // => RelativeDirectPointer<const char, false>
    // => RelativeDirectPointerImpl<const char, false, int32_t>
    /// The name of the type.
    var name: Int32 { get }
    // TargetRelativeDirectPointer<Runtime, const char, /*nullable*/ false> Name;

    /// A pointer to the metadata access function for this type.
    ///
    /// The function type here is a stand-in. You should use getAccessFunction()
    /// to wrap the function pointer in an accessor that uses the proper calling
    /// convention for a given number of arguments.
    var accessFunction: Int32 { get }
    // TargetRelativeDirectPointer<Runtime, MetadataResponse(...), /*nullable*/ true> AccessFunctionPtr;

    /// A pointer to the field descriptor for the type, if any.
    var fields: Int32 { get }
    // TargetRelativeDirectPointer<Runtime, const reflection::FieldDescriptor, /*nullable*/ true> Fields;
}

public protocol TargetTypeContextDescriptor: TargetContextDescriptor where RawValue: RawTargetTypeContextDescriptor {
    var name: String { get }
    var accessFunction: Int32 { get }
    var fields: FieldDescriptor? { get }
    var isReflectable: Bool { get }
//    var accessFunction: UnsafeRawPointer
//    var typeContextDescriptorFlags: TypeContextDescriptorFlags { get}
}

extension TargetTypeContextDescriptor {
//    public var name: String {
//        let name = rawValue.pointee.name
//        guard name != 0, let offset = MemoryLayout.offset(of: \RawValue.name) else {
//            return ""
//        }
//        let c = rawValue.reinterpretCast(to: Int8.self)
//            .advanced(by: offset + Int(name))
//        return String(cString: c)
//    }

    @_transparent
    public var accessFunction: Int32 {
        rawValue.pointee.accessFunction
    }

    public var fields: FieldDescriptor? {
        ContextDescriptor.rawFields(self)
            .map(FieldDescriptor.init(rawValue:))
    }

    @_transparent
    public var isReflectable: Bool {
        rawValue.pointee.fields != 0
    }
}
