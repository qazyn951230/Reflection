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

/// Dumps the given object's contents using its mirror to standard output.
///
/// - Parameters:
///   - value: The value to output to the `target` stream.
///   - name: A label to use when writing the contents of `value`. When `nil`
///     is passed, the label is omitted. The default is `nil`.
///   - indent: The number of spaces to use as an indent for each line of the
///     output. The default is `0`.
///   - maxDepth: The maximum depth to descend when writing the contents of a
///     value that has nested components. The default is `Int.max`.
///   - maxItems: The maximum number of elements for which to write the full
///     contents. The default is `Int.max`.
/// - Returns: The instance passed as `value`.
@discardableResult
@_semantics("optimize.sil.specialize.generic.never")
public func dump<T>(_ value: T, name: String? = nil, indent: Int = 0,
                    maxDepth: Int = Int.max, maxItems: Int = Int.max) -> T {
    var stream = StandardOutput()
    var item = maxItems
    var items = Set<ObjectIdentifier>()
    stream._lock()
    defer {
        stream._unlock()
    }
    _dump(value, kind: Swift.type(of: value) as Any.Type, to: &stream, name: name, indent: indent,
          maxDepth: maxDepth, item: &item, items: &items)
    return value
}

// .../swift/stdlib/public/core/OutputStream.swift!_dumpPrint_unlocked
@_semantics("optimize.sil.specialize.generic.never")
private func _dump<T>(_ value: T, kind: Any.Type, to stream: inout StandardOutput, name: String?,
                      indent: Int, maxDepth: Int, item: inout Int, items: inout Set<ObjectIdentifier>) {
    guard item > 0 else {
        return
    }
    item -= 1
    stream.write(char: 0x20, count: indent)
    let explosion = Explosion(kind)
    stream.write(explosion.propertyCount == 0 ?
        "-" : (maxDepth <= 0 ? "▹" : "▿"))
    stream.write(char: 0x20)
    if let name = name {
        stream.write(name)
        stream.write(": ")
    }
    _dumpSelf(value, kind: kind, explosion, to: &stream)
    stream.write(byte: 0x0A)
    for property in explosion.properties() {
        let child = property.copy(from: value)
//        stream.write(toString(child))
        _dump(child, kind: property.type, to: &stream, name: property.name, indent: indent,
              maxDepth: maxDepth, item: &item, items: &items)
    }
}

@_transparent
func toString<T>(_ value: T) -> String {
    var result = ""
    _print_unlocked(value, &result)
    return result
}

// _dumpPrint_unlocked
private func _dumpSelf(_ value: Any, kind: Any.Type, _ explosion: Explosion,
                       to stream: inout StandardOutput) {
    let metadata = Metadata.load(from: kind)
    if metadata.kind == .struct {
        switch metadata {
        case Int.self:
            stream.write("\(value as! Int)")
            return
        case Bool.self:
            stream.write("\(value as! Bool)")
            return
        default:
            break
        }
    }
    let _kind = metadata.kind
    switch _kind {
    case .class, .struct:
        stream.write("\(_kind) ")
        stream.write(Swift._typeName(kind, qualified: true))
    case .opaque:
        stream.write("\(_kind) ")
    default:
        stream.write("\(_kind) ")
    }
}
