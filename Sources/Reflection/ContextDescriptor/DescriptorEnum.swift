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

// .../swift/include/swift/ABI/Metadata.h!TargetEnumDescriptor

public struct EnumDescriptor: TargetTypeContextDescriptor, TrailingGenericContainer {
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

    public var name: String {
        return String(cString: cName)
    }

    public var fields: FieldDescriptor? {
        let raw = RelativeDirectPointer.resolve(any: rawValue, keyPath: \RawValue.fields)
        return (raw?.reinterpretCast(to: FieldDescriptor.RawValue.self))
            .map(FieldDescriptor.init(rawValue:))
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
    public static func genericArgumentOffset() -> Int? {
        EnumMetadata.genericArgumentOffset()
    }
}
