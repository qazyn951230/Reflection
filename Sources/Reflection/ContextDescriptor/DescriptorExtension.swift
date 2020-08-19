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

// .../swift/include/swift/ABI/Metadata.h!TargetExtensionContextDescriptor

/// Descriptor for an extension context.
public struct ExtensionContextDescriptor: TargetContextDescriptor, TrailingGenericContainer {
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

    public var extendedContext: UnsafePointer<UInt8> {
        // nullable??
        RelativeDirectPointer.resolve(rawValue, keyPath: \RawValue.extendedContext)
            .reinterpretCast(to: UInt8.self)
    }

    public struct RawValue: RawTargetContextDescriptor {
        public let flags: UInt32
        public let parent: Int32
        /// A mangling of the `Self` type context that the extension extends.
        /// The mangled name represents the type in the generic context encoded by
        /// this descriptor. For example, a nongeneric nominal type extension will
        /// encode the nominal type name. A generic nominal type extension will encode
        /// the instance of the type with any generic arguments bound.
        ///
        /// Note that the Parent of the extension will be the module context the
        /// extension is declared inside.
        public let extendedContext: Int32
        // RelativeDirectPointer<const char> ExtendedContext;
    }
}
