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

import CReflection

typealias TypeInfo = CRTypeInfo

@_transparent
func resolveType(byMangledName name: UnsafePointer<UInt8>, metadata: UnsafeRawPointer) -> Any.Type? {
    var info = TypeInfo()
    get_type_by_mangled_name(name, metadata, &info)
    if let metadata = info.metadata {
        return unsafeBitCast(metadata, to: Any.Type.self)
    } else {
        return nil
    }
}

@_transparent
func resolveTypeInfo(byMangledName name: UnsafePointer<UInt8>, metadata: UnsafeRawPointer) -> TypeInfo {
    var info = TypeInfo()
    get_type_by_mangled_name(name, metadata, &info)
    return info
}

@_transparent
func resolveType(byMangledName name: UnsafePointer<UInt8>, in context: UnsafeRawPointer?,
                 arguments: UnsafeRawPointer?) -> Any.Type? {
    let raw = get_type_by_mangled_name_in_context(name, context, arguments)
    if let metadata = raw {
        return unsafeBitCast(metadata, to: Any.Type.self)
    } else {
        return nil
    }
}

// .../swift/stdlib/public/core/KeyPath.swift!_getSymbolicMangledNameLength
func mangledNameLength(_ start: UnsafePointer<UInt8>) -> UInt {
    var end = start
    var current = end.pointee
    while current != 0 {
        // Skip the current character
        end += 1
        if current >= 0x01 && current <= 0x17 {
            end += MemoryLayout<UInt32>.size
        } else if current >= 0x18 && current <= 0x1F {
            end += MemoryLayout<UInt>.size
        }
        end += 1
        current = end.pointee
    }
    return UInt(start.distance(to: end))
}
