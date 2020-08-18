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

@_implementationOnly import CReflection

// SPM did not honor "CReflection.apinotes"
typealias DNodeKind = CRDNodeKind
typealias SymbolicReferenceKind = CRSymbolicReferenceKind
typealias Directness = CRDirectness

class Demangler {
    let ref: demangler_p

    init() {
        ref = demangler_create()
    }

    deinit {
        demangler_free(ref)
    }

    @discardableResult
    func demangleType(mangledName: UnsafePointer<UInt8>) -> DNodeRef? {
        let length = Metadata.mangledNameLength(mangledName)
        let node = demangler_demangle_type(ref, mangledName, length)
        return node.map(DNodeRef.init(ref:))
    }

    @discardableResult
    func demangleType(mangledName: UnsafePointer<UInt8>, // resolver: symbolic_reference_resolver_t
                      resolver: (SymbolicReferenceKind, Directness, Int32, UnsafeRawPointer) -> dnode_p?) -> DNodeRef? {
        let length = Metadata.mangledNameLength(mangledName)
        let node = demangler_demangle_type_block(ref, mangledName, length, resolver)
        return node.map(DNodeRef.init(ref:))
    }

    @discardableResult
    @inlinable
    func createNode(kind: DNodeKind) -> DNodeRef {
        DNodeRef(ref: demangler_create_node(ref, kind))
    }

    @discardableResult
    @inlinable
    func createNode(kind: DNodeKind, pointer: UInt) -> DNodeRef {
        DNodeRef(ref: demangler_create_node_index(ref, kind, pointer))
    }
}

struct DNodeRef {
    let ref: dnode_p

    @inlinable
    func appendChild(_ child: DNodeRef, in demangler: Demangler) {
        dnode_append_child(ref, child.ref, demangler.ref)
    }

    @inlinable
    var kind: DNodeKind {
        dnode_get_kind(ref)
    }

    @inlinable
    var childCount: Int {
        dnode_children_count(ref)
    }

    @inlinable
    var isSpecialized: Bool {
        dnode_is_specialized(ref)
    }

    @inlinable
    var index: UInt64 {
        dnode_get_index(ref)
    }

    @inlinable
    var text: String {
        String(cString: dnode_get_text(ref, nil))
    }

    @inlinable
    func unspecialized(in demangler: Demangler) -> DNodeRef {
        DNodeRef(ref: dnode_get_unspecialized(ref, demangler.ref))
    }

    @inlinable
    func child(at index: Int) -> DNodeRef {
        DNodeRef(ref: dnode_child_at_index(ref, index))
    }

    @inlinable
    func textEquals(_ value: String) -> Bool {
        dnode_is_text_equals(ref, value)
    }

    @inlinable
    subscript(index: Int) -> DNodeRef {
        child(at: index)
    }
}

// .../swift/stdlib/public/runtime/Private.h!swift::ResolveAsSymbolicReference
// ../swift/stdlib/public/runtime/MetadataLookup.cpp!swift::ResolveAsSymbolicReference::operator()
@_transparent
func resolveAsSymbolicReference(demangler: Demangler) -> symbolic_reference_resolver_t {
    return { a, b, c, d in
        _resolveAsSymbolicReference(demangler: demangler, kind: a, directness: b, offset: c, base: d)
    }
}

func _resolveAsSymbolicReference(demangler: Demangler, kind: SymbolicReferenceKind, directness: Directness,
                                 offset: Int32, base: UnsafeRawPointer) -> dnode_p? {
    var addresss = applyRelativeOffset(base, Int(offset))
    if directness == .indirect {
        addresss = UnsafePointer<UInt>(bitPattern: addresss).unsafelyUnwrapped
            .pointee
    }
    let nodeKind: DNodeKind
    let isType: Bool
    switch kind {
    case .context:
        let pointer = UnsafeRawPointer(bitPattern: addresss).unsafelyUnwrapped
        let descriptor = ContextDescriptor.cast(from: pointer)
        switch descriptor.kind {
        case .protocol:
            nodeKind = .protocolSymbolicReference
            isType = false
        case .opaqueType:
            nodeKind = .opaqueTypeDescriptorSymbolicReference
            isType = false
        // descriptor is TargetTypeContextDescriptor
        case .class, .struct, .enum:
            nodeKind = .typeSymbolicReference
            isType = true
        default:
            // References to other kinds of context aren't yet implemented.
            return nil
        }
    case .accessorFunctionReference:
        nodeKind = .accessorFunctionReference
        isType = false
    @unknown default:
        fatalError("Unknown case of SymbolicReferenceKind")
    }
    let node = demangler.createNode(kind: nodeKind, pointer: addresss)
    if isType {
        let typeNode = demangler.createNode(kind: .type)
        typeNode.appendChild(node, in: demangler)
        return typeNode.ref
    } else {
        return node.ref
    }
}

extension Demangler {
    // .../swift/stdlib/public/runtime/Demangle.cpp!swift::_buildDemanglingForContext
    static func buildDemanglingForContext<Descriptor>(context: Descriptor, demangler: Demangler)
        where Descriptor: TargetContextDescriptor {}

    // .../swift/stdlib/public/runtime/Demangle.cpp!swift::_buildDemanglingForNominalType
    static func buildDemanglingForNominalType(metadata: AnyMetadata, demangler: Demangler) {
        switch metadata.kind {
        case .struct:
            break
        default:
            break
        }
        // .../swift/stdlib/public/runtime/Private.h!swift::gatherWrittenGenericArgs
        // .../swift/stdlib/public/runtime/MetadataLookup.cpp!swift::gatherWrittenGenericArgs
    }
}

#endif // ENABLE_REFLECTION_DEMANGLE
