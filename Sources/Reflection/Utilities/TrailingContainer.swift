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

// .../swift/include/swift/ABI/TrailingObjects.h!TrailingObjects

/// A `TrailingContainer` represents such a structure:
///
/// | self  |   v1          |   v2          |
/// | ----- | ------------- | ------------- |
/// |   0   |   v1_count    |   v2_count    |
///
/// then:
/// ```c++
/// v1* t = reinterpret_cast<v1>(this) + v1_count;
/// v2* x = reinterpret_cast<v2>(v1) + v2_count;
/// ```
///
/// If we have an object like:
///
/// ```c++
/// class VarLengthObj : private TrailingObjects<VarLengthObj, int, double> {
///   friend TrailingObjects;
///
///   unsigned NumInts, NumDoubles;
///   size_t numTrailingObjects(OverloadToken<int>) const { return NumInts; }
///  };
/// ```
///
/// the corresponding Swift code is:
///
/// ```swift
/// class VarLengthObj: TrailingContainer {
///     static var trailingTypes: [AnyLayout] {
///         [AnyLayout(Int32.self), AnyLayout(Double.self)]
///     }
///     func trailingObjectsCount(of layout: AnyLayout) -> UInt {
///         switch layout {
///         case Int32.self:
///             return 1 // NumInts
///         default:
///             return 0
///         }
///     }
/// }
/// ```
public protocol TrailingContainer {
    static var trailingTypes: [AnyLayout] { get }

    func trailingObjectsCount(of layout: AnyLayout) -> UInt

    func trailingObjects<T>() -> UnsafePointer<T>
}

extension TrailingContainer {
    @_transparent
    public func trailingObjects<T>(as type: T.Type) -> UnsafePointer<T> {
        trailingObjects()
    }
}

/// Aligns `pointer` to `alignment` bytes, rounding up.
///
/// Alignment should be a power of two.  This method rounds up, so
/// `aligned(7, alignment: 4) == 8` and `aligned(8, alignment: 4) == 8`.
/// ```c++
/// inline uintptr_t alignAddr(const void *Addr, size_t Alignment) {
///   assert(Alignment && isPowerOf2_64((uint64_t)Alignment) &&
///          "Alignment is not a power of two!");
///   assert((uintptr_t)Addr + Alignment - 1 >= (uintptr_t)Addr);
///   return (((uintptr_t)Addr + Alignment - 1) & ~(uintptr_t)(Alignment - 1));
/// }
/// ```
@_transparent
private func aligned(_ pointer: UnsafeRawPointer, alignment: UInt) -> UnsafeRawPointer {
    assert((UInt(bitPattern: pointer) + alignment - 1) >= UInt(bitPattern: pointer))
    let a = UInt(bitPattern: pointer) + alignment - 1
    let b = ~UInt(alignment - 1)
    return UnsafeRawPointer(bitPattern: a & b).unsafelyUnwrapped
}

extension TrailingContainer where Self: UnsafeRawRepresentable {
    private func callObjectsCount(of layout: AnyLayout) -> UInt {
        switch layout {
        case RawValue.self:
            return 1
        default:
            return trailingObjectsCount(of: layout)
        }
    }

    private func resolve(base: UnsafeRawPointer, current: AnyLayout, next: AnyLayout) -> UnsafeRawPointer {
        // let pointer = base.reinterpretCast(to: Current.self)
        //     .advanced(by: Current.self)
        let address = UInt(bitPattern: base) + UInt(current._size) * callObjectsCount(of: current)
        let realignment = current._alignment < next._alignment
        if realignment {
            return aligned(UnsafeRawPointer(bitPattern: address).unsafelyUnwrapped,
                           alignment: UInt(next._alignment))
        } else {
            return UnsafeRawPointer(bitPattern: address).unsafelyUnwrapped
        }
    }

    public func trailingObjects<T>() -> UnsafePointer<T> {
        let target = AnyLayout(T.self)
        let i = Self.trailingTypes.firstIndex { $0 == target }
        guard let count = i else {
            fatalError("Not trailing objects")
        }
        var index = 0
        var current = AnyLayout(RawValue.self)
        var base = rawValue.reinterpretCast()
        var next = Self.trailingTypes[index]
        while index <= count {
            base = resolve(base: base, current: current, next: next)
            index += 1
            current = next
            next = Self.trailingTypes[index]
        }
        return base.reinterpretCast(to: T.self)
    }
}
