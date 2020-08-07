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

/* .../swift/include/swift/ABI/MetadataValues.h */
/// Common flags stored in the first 32-bit word of any context descriptor.
public struct ContextDescriptorKind: OptionSet { // ContextDescriptorFlags
    public var rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    /// The format version of the descriptor. Higher version numbers may have
    /// additional fields that aren't present in older versions.
    @_transparent
    public var version: UInt8 {
        UInt8((rawValue >> UInt32(8)) & UInt32(0xFF))
    }

    /// The most significant two bytes of the flags word, which can have
    /// kind-specific meaning.
    @_transparent
    public var kindSpecificFlags: UInt16 {
        UInt16((rawValue >> UInt32(16)) & UInt32(0xFFFF))
    }

    @_transparent
    public var isGeneric: Bool {
        contains(.generic)
    }

    @_transparent
    public var isUnique: Bool {
        contains(.unique)
    }

    public static let module: ContextDescriptorKind = [] // 0
    public static let `extension` = ContextDescriptorKind(rawValue: 1)
    public static let anonymous = ContextDescriptorKind(rawValue: 2)
    public static let `protocol` = ContextDescriptorKind(rawValue: 3)
    public static let opaqueType = ContextDescriptorKind(rawValue: 4)
    public static let typeFirst = ContextDescriptorKind(rawValue: 16)
    public static let `class` = ContextDescriptorKind(rawValue: 16)
    public static let `struct` = ContextDescriptorKind(rawValue: 17)
    public static let `enum` = ContextDescriptorKind(rawValue: 18)
    public static let generic = ContextDescriptorKind(rawValue: 0x80)
    public static let unique = ContextDescriptorKind(rawValue: 0x40)
}
