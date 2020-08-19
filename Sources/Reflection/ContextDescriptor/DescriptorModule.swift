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

// .../swift/include/swift/ABI/Metadata.h!TargetModuleContextDescriptor

/// Descriptor for a module context.
public struct ModuleContextDescriptor: TargetContextDescriptor {
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

    public struct RawValue: RawTargetContextDescriptor {
        public let flags: UInt32
        public let parent: Int32
        // RelativeDirectPointer<const char, /*nullable*/ false> Name;
        public let name: Int32
    }
}
