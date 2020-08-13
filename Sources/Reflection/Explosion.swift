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

public struct Explosion {
    private let box: ReflectionBox

    public init<T>(type: T.Type) {
        box = ReflectionBox.load(type: type)
    }

    public init(_ type: Any.Type) {
        box = ReflectionBox.load(type: type)
    }

    public var propertyCount: Int {
        box.propertyCount
    }

    public func properties() -> [ReflectedProperty] {
        box.properties()
    }

    public func property(at index: Int) -> ReflectedProperty {
        box.properties()[index]
    }
}

public struct ReflectedProperty {
    public let name: String?
    public let offset: Int?
    public let type: Any.Type?

    init() {
        name = nil
        offset = nil
        type = nil
    }

    init(name: String?, offset: Int?, type: Any.Type?) {
        self.name = name
        self.offset = offset
        self.type = type
    }

    public func value<T, K>(as type: K.Type, from object: T) -> K? {
        guard let offset = self.offset else {
            return nil
        }
        return withUnsafePointer(to: object) { raw in
            raw.reinterpretCast()
                .advanced(by: offset)
                .reinterpretCast(to: type)
                .pointee
        }
    }
}

private class ReflectionBox {
    private var _properties: [ReflectedProperty]?

    var propertyCount: Int {
        0
    }

    final func properties() -> [ReflectedProperty] {
        let p = _properties ?? loadProperties()
        _properties = p
        return p
    }

    func loadProperties() -> [ReflectedProperty] {
        []
    }

    static func load(type: Any.Type) -> ReflectionBox {
        let data = Metadata.load(from: type)
        switch data.kind {
        case .struct:
            return StructReflection(metadata: data.cast())
        default:
            return ReflectionBox()
        }
    }
}

private final class StructReflection: ReflectionBox {
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
        let description = metadata.description
        let offsets = metadata.fieldOffsets
        var result: [ReflectedProperty] = []
        var i = 0
        for record in records {
            let offset: Int?
            if let offsets = offsets {
                offset = Int(offsets.advanced(by: i).pointee)
            } else {
                offset = nil
            }
            let type = Metadata.resolveType(by: record.cMangledTypeName,
                                            context: description.genericContext()?.rawValue.reinterpretCast(),
                                            arguments: description.genericParameters()?.data.reinterpretCast())
            result.append(ReflectedProperty(name: record.fieldName, offset: offset, type: type))
            i += 1
        }
        return result
    }
}
