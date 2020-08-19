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

// .../swift/stdlib/public/runtime/Demangle.cpp!swift::_buildDemanglingForContext
func buildDemanglingForContext(demangler: Demangler, context: ContextDescriptor,
                               generics demangledGenerics: [DNodeRef]) -> DNodeRef {
    var usedDemangledGenerics = 0

    // getGenericArgsTypeListForContext
    func genericArgsTypeList(for context: ContextDescriptor) -> DNodeRef? {
        guard !demangledGenerics.isEmpty,
            context.kind != .anonymous,
            let generics = context.genericContext() else {
            return nil
        }
        let count = Int(generics.fullGenericContextHeader().parametersCount)
        if count <= usedDemangledGenerics {
            return nil
        }
        let list = demangler.createNode(kind: .typeList)
        while usedDemangledGenerics < count {
            list.appendChild(demangledGenerics[usedDemangledGenerics], in: demangler)
            usedDemangledGenerics += 1
        }
        return list
    }

    let tree = context.tree().reversed()
    guard let module = tree.first.map({ moduleNode(in: demangler, context: $0) }) else {
        fatalError("module should be top level")
    }
    var current = module
    let descriptorPath = tree.dropFirst()
    for component in descriptorPath {
        switch component.kind {
        case .module:
            assertionFailure("module should be top level")
        case .extension:
            current = extensionNode(in: demangler, context: component, node: current, args: genericArgsTypeList)
        case .protocol:
            current = protocolNode(in: demangler, context: component, node: current)
        case .struct, .class, .enum:
            // Form a type context demangling for type contexts.
            fallthrough
        default:
            fatalError()
        }
    }
    // Wrap the final result in a top-level Type node.
    let top = demangler.createNode(kind: .type)
    top.appendChild(current, in: demangler)
    return top
}

@inline(__always)
private func moduleNode(in demangler: Demangler, context: ContextDescriptor) -> DNodeRef {
    assert(context.kind == .module)
    let name = context.as(ModuleContextDescriptor.self).cName
    return demangler.createNode(kind: .module, text: name)
}

@inline(__always)
private func extensionNode(in demangler: Demangler, context: ContextDescriptor, node: DNodeRef,
                           args genericArgsTypeList: (ContextDescriptor) -> DNodeRef?) -> DNodeRef {
    assert(context.kind == .extension)
    let extendedContext = context.as(ExtensionContextDescriptor.self).extendedContext
    // Demangle the extension self type.
    var selfType = demangler.demangleType(
        mangledName: extendedContext,
        resolver: resolveToDemanglingForContext(in: demangler)
    ).unsafelyUnwrapped
    if selfType.kind == .type {
        selfType = selfType.child(at: 0)
    }
    // Substitute in the generic arguments.
    let argsList = genericArgsTypeList(context)
    switch selfType.kind {
    case .boundGenericEnum, .boundGenericStructure,
         .boundGenericClass, .boundGenericOtherNominalType:
        if let genericArgsList = argsList {
            let subSelfType = demangler.createNode(kind: selfType.kind)
            subSelfType.appendChild(selfType.child(at: 0), in: demangler)
            subSelfType.appendChild(genericArgsList, in: demangler)
            selfType = subSelfType
        }
    default:
        // TODO: Use the unsubstituted type if we can't handle the
        // substitutions yet.
        selfType = selfType.child(at: 0).child(at: 0)
    }
    let extNode = demangler.createNode(kind: .extension)
    extNode.appendChild(node, in: demangler)
    extNode.appendChild(selfType, in: demangler)
    // TODO: Turn the generic signature into a demangling as the third
    // generic argument.
    return extNode
}

@inline(__always)
private func protocolNode(in demangler: Demangler, context: ContextDescriptor, node: DNodeRef) -> DNodeRef {
    assert(context.kind == .protocol)
    let proto = context.as(ProtocolDescriptor.self)
    let protoNode = demangler.createNode(kind: .protocol)
    protoNode.appendChild(node, in: demangler)
    let nameNode = demangler.createNode(kind: .identifier, text: proto.cName)
    protoNode.appendChild(nameNode, in: demangler)
    return protoNode
}

@inline(__always)
private func typeContextNode(in demangler: Demangler, context: ContextDescriptor, node: DNodeRef) -> DNodeRef {
    let nodeKind: DNodeKind
    let genericNodeKind: DNodeKind
    fatalError()
}

#endif // ENABLE_REFLECTION_DEMANGLE
