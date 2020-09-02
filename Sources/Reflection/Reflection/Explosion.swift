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

enum ReflectedKind {
    case structure(ReflectionBox)
    case collection(ReflectedCollection)
    case builtin(ReflectedLeaf)
}

public struct Explosion {
    private let kind: ReflectedKind

    public init<T>(type: T.Type) {
        self.init(box: ReflectionBox.load(type: type))
    }

    public init(_ type: Any.Type) {
        self.init(box: ReflectionBox.load(type: type))
    }

    public init(of value: Any) {
        let raw = unsafeBitCast(type(of: value), to: UnsafePointer<Metadata.RawValue>.self)
        self.init(box: ReflectionBox.load(metadata: Metadata(rawValue: raw)))
    }
    
    init(box: ReflectionBox) {
        kind = .structure(box)
    }
    
    init(collection: ReflectedCollection) {
        kind = .collection(collection)
    }
    
    init(leaf: ReflectedLeaf) {
        kind = .builtin(leaf)
    }

    public var propertyCount: Int {
        switch kind {
        case let .structure(box):
            return box.propertyCount
        default:
            return 0
        }
    }

    public func properties() -> [ReflectedProperty] {
        switch kind {
        case let .structure(box):
            return box.properties
        default:
            return []
        }
    }

    func property(at index: Int) -> ReflectedProperty {
        switch kind {
        case let .structure(box):
            return box.properties[index]
        default:
            fatalError()
        }
    }
}

class ReflectionBox {
    var propertyCount: Int { 0 }
    final lazy var properties: [ReflectedProperty] = loadProperties()

    func loadProperties() -> [ReflectedProperty] {
        []
    }

    static func load(type: Any.Type) -> ReflectionBox {
        load(metadata: Metadata.load(from: type))
    }

    static func load(metadata: Metadata) -> ReflectionBox {
        switch metadata.kind {
        case .struct:
            return StructReflection(metadata: metadata.cast())
        default:
            return ReflectionBox()
        }
    }
}

struct ReflectedCollection {
    let children: [ReflectedElement]
}

protocol ReflectedLeaf {
    func write(to stream: inout StandardOutput)
}

final class StructReflection: ReflectionBox {
    let metadata: StructMetadata

    init(metadata: StructMetadata) {
        self.metadata = metadata
    }

    override var propertyCount: Int {
        Int(metadata.description.fieldCount)
    }

    override func loadProperties() -> [ReflectedProperty] {
        guard metadata.isReflectable,
            let records = metadata.description.fields?.fieldRecords() else {
            return []
        }
//        let description = metadata.description
        let offsets = metadata.fieldOffsets
//        let context = description.genericContext()?.rawValue.reinterpretCast()
//        let arguments = description.genericParameters()?.data.reinterpretCast()

        var result: [ReflectedProperty] = []
        var i = 0
        for record in records {
            let offset = offsets?.advanced(by: i).pointee
//            let type = Metadata.resolveType(by: record.cMangledTypeName.reinterpretCast(to: UInt8.self),
//                                            context: context, arguments: arguments)
            let type = resolveType(byMangledName: record.cMangledTypeName.reinterpretCast(to: UInt8.self),
                                   metadata: metadata.rawValue.reinterpretCast())
            if let o = offset, let t = type {
                let p = StructProperty(metadata: metadata, name: record.fieldName,
                                       mangledTypeName: record.cMangledTypeName, offset: o, type: t)
                result.append(p)
            } else {
                assertionFailure("Something wrong?")
            }
            i += 1
        }
        return result
    }
}

@_silgen_name("copy_struct_field")
func copyStructField<T>(metadata: UnsafePointer<StructMetadata.RawValue>, name: UnsafePointer<Int8>,
                        fieldOffset: UInt32, value: T) -> Any

@_silgen_name("copy_enum_field")
func copyEnumField<T>(metadata: UnsafePointer<EnumMetadata.RawValue>, name: UnsafePointer<Int8>,
                      indirect: Bool, value: T) -> Any

@_silgen_name("copy_class_field")
func copyClassField<T>(metadata: UnsafePointer<ClassMetadata.RawValue>, name: UnsafePointer<Int8>,
                       index: Int, value: T) -> Any
