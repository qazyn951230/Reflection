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

// FixedWidthInteger: BinaryInteger
// static func & (lhs: Self, rhs: Self) -> Self
// static func >> <RHS>(lhs: Self, rhs: RHS) -> Self where RHS : BinaryInteger
public protocol FlagSet: RawRepresentable where RawValue: FixedWidthInteger {
    var rawValue: RawValue { get mutating set }

    init(rawValue: RawValue)

    /// Read a single-bit flag.
    func readBit(offset: UInt32) -> Bool
    mutating func writeBit(_ value: Bool, offset: UInt32)

    /// Read a multi-bit field.
    func readBit<T>(offset: UInt32, width: UInt32) -> T where T: FixedWidthInteger
    mutating func writeBit<T>(_ value: T, offset: UInt32, width: UInt32) where T: FixedWidthInteger
}

@_transparent
private func lowMask(for width: UInt32) -> UInt32 {
    (1 << width) - 1
}

@_transparent
private func mask(_ offset: UInt32, width: UInt32) -> UInt32 {
    lowMask(for: width) << offset
}

extension FlagSet {
    public func readBit(offset: UInt32) -> Bool {
        (rawValue & RawValue(mask(offset, width: 1))) != 0
    }

    public mutating func writeBit(_ value: Bool, offset: UInt32) {
        if value {
            rawValue |= RawValue(mask(offset, width: 1))
        } else {
            rawValue &= RawValue(~mask(offset, width: 1))
        }
    }

    public func readBit<T>(offset: UInt32, width: UInt32) -> T where T: FixedWidthInteger {
        T((rawValue >> offset) & RawValue(lowMask(for: width)))
    }

    public mutating func writeBit<T>(_ value: T, offset: UInt32, width: UInt32) where T: FixedWidthInteger {
        rawValue = (rawValue & RawValue(~mask(offset, width: width))) |
            RawValue(value) << offset
    }
}
