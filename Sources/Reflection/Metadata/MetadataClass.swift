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

/// The structure of all class metadata.  This structure is embedded
/// directly within the class's heap metadata structure and therefore
/// cannot be extended without an ABI break.
///
/// Note that the layout of this type is compatible with the layout of
/// an Objective-C class.
public struct ClassMetadata: TargetAnyClassMetadata { // TargetClassMetadata
    public let rawValue: UnsafePointer<RawValue>
    public let description: ClassDescriptor

    public init(rawValue: UnsafePointer<RawValue>) {
        self.rawValue = rawValue
        description = ClassDescriptor.cast(from: rawValue.pointee.description)
    }

    public struct RawValue: RawTargetAnyClassMetadata {
        public let kind: UInt
        public let superclass: UnsafeRawPointer

#if SWIFT_OBJC_INTEROP
        public let cachedData1: UnsafeRawPointer
        public let cachedData2: UnsafeRawPointer
        public let data: UInt
#endif

        public let flags: UInt32 // ClassFlags
        public let instanceAddressPoint: UInt32
        public let instanceSize: UInt32
        public let instanceAlignMask: UInt16
        public let reserved: UInt16
        public let classSize: UInt32
        public let classAddressPoint: UInt32
        // TargetSignedPointer<Runtime, const TargetClassDescriptor<Runtime> *> Description;
        // => template <typename Runtime, typename T>
        //    using TargetSignedPointer = typename Runtime::template SignedPointer<T>;
        // => T
        // => const TargetClassDescriptor<Runtime> *
        public let description: UnsafeRawPointer
        // TargetSignedPointer<Runtime, ClassIVarDestroyer *> IVarDestroyer;
        public let ivarDestroyer: UnsafeRawPointer

        // After this come the class members, laid out as follows:
        //   - class members for the superclass (recursively)
        //   - metadata reference for the parent, if applicable
        //   - generic parameters for this class
        //   - class variables (if we choose to support these)
        //   - "tabulated" virtual methods
    }
}
