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

/// Kinds of context descriptor.
public enum ContextDescriptorKind: UInt8 {
    case module = 0
    case `extension` = 1
    case anonymous = 2
    case `protocol` = 3
    case opaqueType = 4
    case `class` = 16
    case `struct` = 17
    case `enum` = 18
}

/// Common flags stored in the first 32-bit word of any context descriptor.
public struct ContextDescriptorFlags: OptionSet {
    public var rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    /// The kind of context this descriptor describes.
    @_transparent
    public var kind: ContextDescriptorKind {
        ContextDescriptorKind(rawValue: UInt8(rawValue & 0x1F)) ?? ContextDescriptorKind.opaqueType
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

    public static let generic = ContextDescriptorFlags(rawValue: 0x80)
    public static let unique = ContextDescriptorFlags(rawValue: 0x40)
}
