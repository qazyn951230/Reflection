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

public protocol TrailingContainer {
    static var trailingTypes: [Any.Type] { get }

    static func trailingObjectsCount(of metadata: Metadata) -> Int
    static func trailingObjectsSize(of metadata: Metadata) -> Int
    static func trailingObjectsAlignment(of metadata: Metadata) -> Int

    func trailingObjects<T>() -> UnsafePointer<T>
}

/// Aligns \c Addr to \c Alignment bytes, rounding up.
///
/// Alignment should be a power of two.  This method rounds up, so
/// alignAddr(7, 4) == 8 and alignAddr(8, 4) == 8.
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
    private static func callObjectsCount(of metadata: Metadata) -> Int {
        switch metadata {
        case RawValue.self:
            return 1
        default:
            return trailingObjectsCount(of: metadata)
        }
    }

    private static func callObjectsSize(of metadata: Metadata) -> UInt {
        switch metadata {
        case RawValue.self:
            return UInt(MemoryLayout<RawValue>.size)
        default:
            return UInt(trailingObjectsSize(of: metadata))
        }
    }

    private static func callObjectsAlignment(of metadata: Metadata) -> UInt {
        switch metadata {
        case RawValue.self:
            return UInt(MemoryLayout<RawValue>.alignment)
        default:
            return UInt(trailingObjectsAlignment(of: metadata))
        }
    }

    private static func resolve(base: UnsafeRawPointer, current: Metadata, next: Metadata) -> UnsafeRawPointer {
        let pointer = UInt(bitPattern: base) + callObjectsSize(of: current)
        let realignment = callObjectsAlignment(of: current) < callObjectsAlignment(of: next)
        if realignment {
            return aligned(UnsafeRawPointer(bitPattern: pointer).unsafelyUnwrapped,
                           alignment: callObjectsAlignment(of: next))
        } else {
            return UnsafeRawPointer(bitPattern: pointer).unsafelyUnwrapped
        }
    }

    public func trailingObjects<T>() -> UnsafePointer<T> {
        let target = Metadata.load(from: T.self)
        let i = Self.trailingTypes.firstIndex { $0 == target }
        guard let count = i else {
            fatalError("Not trailing objects")
        }
        var index = 0
        var current = Metadata.load(from: RawValue.self)
        var base = rawValue.reinterpretCast()
        var next = Metadata.load(from: Self.trailingTypes[index])
        while index <= count {
            base = Self.resolve(base: base, current: current, next: next)
            index += 1
            current = next
            next = Metadata.load(from: Self.trailingTypes[index])
        }
        return base.reinterpretCast(to: T.self)
    }

    @_transparent
    public func trailingObjects<T>(as type: T.Type) -> UnsafePointer<T> {
        trailingObjects()
    }
}
