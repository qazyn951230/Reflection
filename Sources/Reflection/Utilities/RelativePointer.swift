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

enum RelativeDirectPointer {
    @_transparent
    static func resolve(_ base: UnsafeRawPointer, _ offset: Int,
                        offset memberOffset: Int = 0) -> UnsafeRawPointer {
        base.advanced(by: offset + memberOffset)
    }

    @_transparent
    static func resolve(any base: UnsafeRawPointer, _ offset: Int,
                        offset memberOffset: Int = 0) -> UnsafeRawPointer? {
        offset == 0 ? nil : base.advanced(by: offset + memberOffset)
    }

    @_transparent
    static func resolve<Root, Value>(_ base: UnsafePointer<Root>, keyPath: KeyPath<Root, Value>)
        -> UnsafeRawPointer where Value: FixedWidthInteger {
        let offset = MemoryLayout<Root>.offset(of: keyPath) ?? 0
        let value = Int(base.pointee[keyPath: keyPath])
        return resolve(base.reinterpretCast(), value, offset: offset)
    }

    @_transparent
    static func resolve<Root, Value>(any base: UnsafePointer<Root>, keyPath: KeyPath<Root, Value>)
        -> UnsafeRawPointer? where Value: FixedWidthInteger {
        let value = Int(base.pointee[keyPath: keyPath])
        guard value != 0, let offset = MemoryLayout<Root>.offset(of: keyPath) else {
            return nil
        }
        return resolve(base.reinterpretCast(), value, offset: offset)
    }
}

/// ```c++
/// template<typename BasePtrTy, typename Offset>
/// static inline uintptr_t applyRelativeOffset(BasePtrTy *basePtr, Offset offset) {
///     auto base = reinterpret_cast<uintptr_t>(basePtr);
///     auto extendOffset = (uintptr_t)(intptr_t)offset;
///     return base + extendOffset;
/// }
/// ```
@_transparent
func applyRelativeOffset(_ base: UnsafeRawPointer, _ offset: Int) -> UInt {
    let (result, _) = UInt(bitPattern: base).addingReportingOverflow(UInt(bitPattern: offset))
    return result
}

/// A relative reference to an object stored in memory. The reference may be
/// direct or indirect, and uses the low bit of the (assumed at least
/// 2-byte-aligned) pointer to differentiate.
/// ```c++
/// template<typename ValueTy, bool Nullable = false, typename Offset = int32_t>
/// class RelativeIndirectablePointer
/// ```
enum RelativeIndirectablePointer {
    @_transparent
    static func resolve(_ base: UnsafeRawPointer, _ offset: Int,
                        offset memberOffset: Int = 0) -> UnsafeRawPointer {
        let t = applyRelativeOffset(base.advanced(by: memberOffset), offset & -1)
        let address = UnsafeRawPointer(bitPattern: t) ?? base // Ignore casting failure
        // If the low bit is set, then this is an indirect address. Otherwise,
        // it's direct.
        if offset & 1 != 0 {
            // return *reinterpret_cast<const ValueTy * const *>(address);
            return address.reinterpretCast(to: UnsafeRawPointer.self).pointee
        } else {
            // return reinterpret_cast<const ValueTy *>(address)
            return address
        }
    }

    @_transparent
    static func resolve(any base: UnsafeRawPointer, _ offset: Int,
                        offset memberOffset: Int = 0) -> UnsafeRawPointer? {
        offset == 0 ? nil : resolve(base, offset, offset: memberOffset)
    }

    @_transparent
    static func resolve<Root, Value>(_ base: UnsafePointer<Root>, keyPath: KeyPath<Root, Value>)
        -> UnsafeRawPointer where Value: FixedWidthInteger {
        let offset = MemoryLayout<Root>.offset(of: keyPath) ?? 0
        let value = Int(base.pointee[keyPath: keyPath])
        return resolve(base.reinterpretCast(), value, offset: offset)
    }

    @_transparent
    static func resolve<Root, Value>(any base: UnsafePointer<Root>, keyPath: KeyPath<Root, Value>)
        -> UnsafeRawPointer? where Value: FixedWidthInteger {
        let value = Int(base.pointee[keyPath: keyPath])
        guard value != 0, let offset = MemoryLayout<Root>.offset(of: keyPath) else {
            return nil
        }
        return resolve(base.reinterpretCast(), value, offset: offset)
    }
}
