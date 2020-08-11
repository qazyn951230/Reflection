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

public struct ExistentialTypeFlags: RawRepresentable {
    public typealias RawValue = UInt32

    public let rawValue: UInt32

    public init?(rawValue: UInt32) {
        self.init(rawValue)
    }

    public init(_ rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public var hasSuperclassConstraint: Bool {
        (rawValue & ExistentialTypeFlags.hasSuperclassMask) != 0
    }

    private static let numWitnessTablesMask: UInt32 = 0x00FF_FFFF
    private static let classConstraintMask: UInt32 = 0x8000_0000
    private static let hasSuperclassMask: UInt32 = 0x4000_0000
    private static let specialProtocolMask: UInt32 = 0x3F00_0000
    private static let specialProtocolShift: UInt32 = 24
}
