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

import Darwin.C

// .../swift/stdlib/public/core/OutputStream.swift
struct StandardOutput: TextOutputStream {
    init() {
        // Do nothing.
    }
    
    // https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/flockfile.3.html
    mutating func _lock() {
        flockfile(stdout)
    }
    
    mutating func _unlock() {
        funlockfile(stdout)
    }
    
    mutating func write(_ string: String) {
        if string.isEmpty {
            return
        }
        var foobar = string
        foobar.withUTF8 { p -> Void in
            if let base = p.baseAddress {
                fwrite(base, 1, p.count, stdout)
            } else {
#if DEBUG
                fatalError()
#endif
            }
        }
    }
    
    mutating func write(byte: UInt8) {
        fputc(Int32(byte), stdout)
    }
    
    mutating func write(char: Int32) {
        fputc(char, stdout)
    }
    
    mutating func write(byte: UInt8, count: Int) {
        write(char: Int32(byte), count: count)
    }
    
    mutating func write(char: Int32, count: Int) {
        for _ in 0 ..< count {
            fputc(char, stdout)
        }
    }
    
    // https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/fwrite.3.html
    mutating func write(_ string: UnsafePointer<UInt8>, lenght: Int) {
        fwrite(string.reinterpretCast(), 1, lenght, stdout)
    }
    
    mutating func write(_ string: UnsafePointer<UInt8>) {
        var p = string
        while p.pointee != 0 {
            fwrite(p.reinterpretCast(), 1, 1, stdout)
            p += 1
        }
    }
}
