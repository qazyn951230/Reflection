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

#if ENABLE_REFLECTION_DEMANGLE

import Darwin.C
@_implementationOnly import CReflection

func mangleNode(_ node: DNodeRef) -> String {
    var name = ""
    remangle_node(node.ref) { (data, size) in
        name = String(cString: data, size: size)
    }
    return name
}

func mangleNode(_ node: DNodeRef, resolver: symbolic_resolver_t) -> String {
    var name = ""
    remangle_node_block(node.ref, resolver) { (data, size) in
        name = String(cString: data, size: size)
    }
    return name
}

func mangleNode(_ node: DNodeRef, resolver: symbolic_resolver_t, in demangler: Demangler) -> String {
    var name = ""
    remangle_node_factory(node.ref, resolver, demangler.ref) { (data, size) in
        name = String(cString: data, size: size)
    }
    return name
}

extension String {
    public init(cString: UnsafePointer<CChar>, size: Int) {
        if cString.advanced(by: size).pointee == 0 || strnlen(cString, size) <= size {
            self.init(cString: cString)
        } else {
            let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: size + 1)
            defer {
                buffer.deallocate()
            }
            buffer.initialize(from: cString, count: size)
            buffer.advanced(by: size + 1).pointee = 0
            self.init(cString: buffer)
        }
    }
    
    public init(cString: UnsafePointer<UInt8>, size: Int) {
        if cString.advanced(by: size).pointee == 0 || strnlen(cString.reinterpretCast(to: Int8.self), size) <= size {
            self.init(cString: cString)
        } else {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size + 1)
            defer {
                buffer.deallocate()
            }
            buffer.initialize(from: cString, count: size)
            buffer.advanced(by: size + 1).pointee = 0
            self.init(cString: buffer)
        }
    }
}

#endif // ENABLE_REFLECTION_DEMANGLE
