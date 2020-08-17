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
    _dump(value, to: &stream, name: name, indent: indent, maxDepth: maxDepth, item: &item, items: &items)
    return value
}

// @_semantics("optimize.sil.specialize.generic.never")
private func _dump(_ value: Any, to stream: inout StandardOutput, name: String?, indent: Int,
                   maxDepth: Int, item: inout Int, items: inout Set<ObjectIdentifier>) {
    guard item > 0 else {
        return
    }
    item -= 1
    stream.write(char: 0x20, count: indent)
    let explosion = Explosion(type(of: value))
    stream.write(explosion.propertyCount == 0 ?
        "-" : (maxDepth <= 0 ? "▹" : "▿"))
    stream.write(char: 0x20)
    if let name = name {
        stream.write(name)
        stream.write(": ")
    }
    _dumpSelf(value, explosion, to: &stream)
    stream.write(byte: 0x0A)
    for property in explosion.properties() {
        if let type = property.type {
            stream.write(Swift._typeName(type, qualified: true))
        }
        if let name = property.name, let offset = property.offset {
            stream.write(" name: \(name), \(offset)\n")
        }
//        _dumpSelf(<#T##value: Any##Any#>, <#T##explosion: Explosion##Explosion#>, to: &<#T##StandardOutput#>)
    }
}

// .../swift/stdlib/public/core/OutputStream.swift!_dumpPrint_unlocked
// @_semantics("optimize.sil.specialize.generic.never")
private func _dumpSelf(_ value: Any, _ explosion: Explosion, to stream: inout StandardOutput) {
    let type: Any.Type = Swift.type(of: value)
    let metadata = Metadata.load(from: type)
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
    let kind = metadata.kind
    switch kind {
    case .class, .struct:
        stream.write("\(kind) ")
        stream.write(Swift._typeName(type, qualified: true))
//        stream.write(_typeName(type, kind: kind))
    default:
        break
    }
}

#if ENABLE_REFLECTION_DEMANGLE

// `_typeName` call stack:
// .../swift/stdlib/public/core/Misc.swift!_typeName
// .../swift/include/swift/Runtime/HeapObject.h!swift::swift_getTypeName
// .../swift/stdlib/public/runtime/Casting.cpp!swift::swift_getTypeName
// .../swift/stdlib/public/runtime/Casting.cpp!swift::nameForMetadata
// .../swift/stdlib/public/runtime/Casting.cpp!_buildNameForMetadata
// .../swift/stdlib/public/runtime/Private.h!swift::_swift_buildDemanglingForMetadata
// .../swift/stdlib/public/runtime/Demangle.cpp!swift::_swift_buildDemanglingForMetadata
// .../swift/stdlib/public/runtime/Demangle.cpp!swift::_buildDemanglingForNominalType
// .../swift/stdlib/public/runtime/Demangle.cpp!swift::_buildDemanglingForContext
// .../swift/lib/Demangling/NodePrinter.cpp!Demangle::nodeToString
// .../swift/lib/Demangling/NodePrinter.cpp!NodePrinter::printRoot
// .../swift/lib/Demangling/NodePrinter.cpp!NodePrinter::print(NodePointer, bool/*asPrefixContext = false*/)
private func _typeName(_ type: Any.Type, kind: Metadata.Kind, qualified: Bool = true) -> String {
    switch kind {
    case .struct:
        return _typeName(struct: StructMetadata.load(from: type), qualified: qualified)
    case .class:
        return _typeName(class: ClassMetadata.load(from: type), qualified: qualified)
    default:
        return ""
    }
}

private func _typeName(struct value: StructMetadata, qualified: Bool) -> String {
    qualified ? _qualifiedTypeName(value.description) : value.description.name
}

private func _typeName(class value: ClassMetadata, qualified: Bool) -> String {
    qualified ? _qualifiedTypeName(value.description) : value.description.name
}

private func _qualifiedTypeName<T>(_ description: T) -> String where T: TargetContextDescriptor {
    var names: [String] = []
    var i: ContextDescriptor? = ContextDescriptor(other: description)
    while let t = i {
        switch t.kind {
        case .struct:
            names.append(t.as(StructDescriptor.self).name)
        case .module:
            names.append(t.as(ModuleContextDescriptor.self).name)
        default:
            break
        }
        i = t.parent
    }
    return names.reversed().joined(separator: ".")
}

#endif // ENABLE_REFLECTION_DEMANGLE
