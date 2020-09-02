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

/// The structure of type metadata for structs.
public struct StructMetadata: TargetValueMetadata { // TargetStructMetadata
    public typealias RawValue = ValueMetadata.RawValue

    public let rawValue: UnsafePointer<RawValue>
    public let description: StructDescriptor

    public init(rawValue: UnsafePointer<RawValue>) {
        self.rawValue = rawValue
        description = StructDescriptor.cast(from: rawValue.pointee.description)
    }

    // The first trailing field of struct metadata is always the generic
    // argument array.

    /// Get a pointer to the field offset vector, if present, or null.
    var fieldOffsets: UnsafePointer<UInt32>? {
        let offset = description.fieldOffsetVectorOffset
        if offset == 0 {
            return nil
        }
        // auto asWords = reinterpret_cast<const void * const*>(this);
        // return reinterpret_cast<const uint32_t *>(asWords + offset);
        return rawValue.reinterpretCast(to: UnsafeRawPointer.self)
            .advanced(by: Int(offset))
            .reinterpretCast(to: UInt32.self)
    }

    public func fieldOffset(at index: Int) -> Int? {
        guard let list = fieldOffsets, index < description.fieldCount else {
            return nil
        }
        return Int(list.advanced(by: index).pointee)
    }

    @_transparent
    public var isReflectable: Bool {
        description.isReflectable
    }
}
