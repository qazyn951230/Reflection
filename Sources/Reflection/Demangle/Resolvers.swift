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

/// Symbolic reference resolver that resolves the absolute addresses of
/// symbolic references but leaves them as references.
@_transparent
// .../swift/stdlib/public/runtime/Private.h!swift::ResolveAsSymbolicReference
// ../swift/stdlib/public/runtime/MetadataLookup.cpp!swift::ResolveAsSymbolicReference::operator()
func resolveAsSymbolicReference(in demangler: Demangler) -> symbolic_reference_resolver_t {
    return { a, b, c, d in
        _resolveAsSymbolicReference(demangler: demangler, kind: a, directness: b, offset: c, base: d)
    }
}

/// Demangler resolver that turns resolved symbolic references into their
/// demangling trees.
@_transparent
func expandResolvedSymbolicReferences(in demangler: Demangler) -> symbolic_resolver_t {
    return { a, b in
        buildDemanglingForSymbolicReference(demangler: demangler, kind: a, resolvedReference: b)
    }
}

/// Symbolic reference resolver that produces the demangling tree for the
/// referenced context.
func resolveToDemanglingForContext(in demangler: Demangler) -> symbolic_reference_resolver_t {
    // .../swift/stdlib/public/runtime/Private.h!swift::ResolveToDemanglingForContext
    // ../swift/stdlib/public/runtime/MetadataLookup.cpp!swift::ResolveToDemanglingForContext::operator()
    return { a, b, c, d in
        _resolveToDemanglingForContext(demangler: demangler, kind: a, directness: b, offset: c, base: d)
    }
}

private func _resolveAsSymbolicReference(demangler: Demangler, kind: SymbolicReferenceKind, directness: Directness,
                                         offset: Int32, base: UnsafeRawPointer) -> dnode_p? {
    let addresss: UInt
    if directness == .indirect {
        addresss = UnsafePointer<UInt>(bitPattern: applyRelativeOffset(base, Int(offset)))
            .unsafelyUnwrapped
            .pointee
    } else {
        addresss = applyRelativeOffset(base, Int(offset))
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

private func _resolveToDemanglingForContext(demangler: Demangler, kind: SymbolicReferenceKind, directness: Directness,
                                            offset: Int32, base: UnsafeRawPointer) -> dnode_p? {
    let addresss: UInt
    if directness == .indirect {
        addresss = UnsafePointer<UInt>(bitPattern: applyRelativeOffset(base, Int(offset)))
            .unsafelyUnwrapped
            .pointee
    } else {
        addresss = applyRelativeOffset(base, Int(offset))
    }
    return buildDemanglingForSymbolicReference(demangler: demangler, kind: kind, resolvedReference: base)
}

#endif // ENABLE_REFLECTION_DEMANGLE
