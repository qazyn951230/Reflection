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

// .../swift/include/swift/Reflection/Records.h
/// Field descriptors contain a collection of field records for a single
/// class, struct or enum declaration.
public struct FieldDescriptor: UnsafeRawRepresentable {
    public let rawValue: UnsafePointer<RawValue>

    public init(rawValue: UnsafePointer<RawValue>) {
        self.rawValue = rawValue
    }

    public var mangledTypeName: UnsafePointer<UInt8> {
        let name = rawValue.pointee.mangledTypeName
        return rawValue.reinterpretCast(to: UInt8.self)
            .advanced(by: Int(name))
    }

    public var kind: Kind {
        Kind(rawValue: rawValue.pointee.kind) ?? Kind.struct
    }

    public struct RawValue {
        // const RelativeDirectPointer<const char> MangledTypeName;
        public let mangledTypeName: Int32
        // const RelativeDirectPointer<const char> Superclass;
        public let superclass: Int32
        public let kind: UInt16 // FieldDescriptorKind
        public let fieldRecordSize: UInt16
        public let fieldsCount: UInt32 // NumFields
    }

    public enum Kind: UInt16 {
        case `struct`
        case `class`
        case `enum`
        // Fixed-size multi-payload enums have a special descriptor format that
        // encodes spare bits.
        //
        // FIXME: Actually implement this. For now, a descriptor with this kind
        // just means we also have a builtin descriptor from which we get the
        // size and alignment.
        case multiPayloadEnum
        // A Swift opaque protocol. There are no fields, just a record for the
        // type itself.
        case `protocol`
        // A Swift class-bound protocol.
        case classProtocol
        // An Objective-C protocol, which may be imported or defined in Swift.
        case objCProtocol
        // An Objective-C class, which may be imported or defined in Swift.
        // In the former case, field type metadata is not emitted, and
        // must be obtained from the Objective-C runtime.
        case objCClass
    }
}

public struct FieldRecord: UnsafeRawRepresentable {
    public let rawValue: UnsafePointer<RawValue>

    public init(rawValue: UnsafePointer<RawValue>) {
        self.rawValue = rawValue
    }

    public var mangledTypeName: String? {
        let c = RelativeDirectPointer.resolve(any: rawValue, keyPath: \RawValue.mangledTypeName)
        return (c?.reinterpretCast(to: Int8.self))
            .map(String.init(cString:))
    }

    var cMangledTypeName: UnsafePointer<UInt8> {
        RelativeDirectPointer.resolve(rawValue, keyPath: \RawValue.mangledTypeName)
            .reinterpretCast(to: UInt8.self)
    }

    public var fieldName: String? {
        let c = RelativeDirectPointer.resolve(any: rawValue, keyPath: \RawValue.fieldName)
        return (c?.reinterpretCast(to: Int8.self))
            .map(String.init(cString:))
    }

    public struct RawValue {
        public let flags: UInt32
        // const RelativeDirectPointer<const char> MangledTypeName;
        public let mangledTypeName: Int32
        // const RelativeDirectPointer<const char> FieldName;
        public let fieldName: Int32
    }
}

extension FieldDescriptor {
    public func fieldRecords() -> ArrayRef<FieldRecord, FieldRecord.RawValue> {
        ArrayRef(start: rawValue.advanced(by: 1).reinterpretCast(to: FieldRecord.RawValue.self),
                 count: Int(rawValue.pointee.fieldsCount))
    }
}
