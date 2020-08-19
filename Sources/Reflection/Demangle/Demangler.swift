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

    @discardableResult
    @inlinable
    func createNode(kind: DNodeKind, text: UnsafePointer<Int8>) -> DNodeRef {
        DNodeRef(ref: demangler_create_node_char(ref, kind, text))
    }

    @discardableResult
    @inlinable
    func createNode(kind: DNodeKind, text: UnsafePointer<UInt8>) -> DNodeRef {
        DNodeRef(ref: demangler_create_node_uint8(ref, kind, text))
    }
}

// .../swift/stdlib/public/runtime/Demangle.cpp!swift::_buildDemanglingForContext
func buildDemanglingForContext(demangler: Demangler, context: ContextDescriptor,
                               demangledGenerics: [DNodeRef]) -> dnode_p {
    // getGenericArgsTypeListForContext
    func genericArgsTypeList(for descriptor: ContextDescriptor) -> DNodeRef? {
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

    var usedDemangledGenerics = 0
    var node: DNodeRef?
    let descriptorPath = context.parents().reversed()
    for component in descriptorPath {
        switch component.kind {
        case .module:
            assert(node == nil, "module should be top level")
            let name = component.as(ModuleContextDescriptor.self).cName
            node = demangler.createNode(kind: .module, text: name)
        case .extension:
            let extendedContext = component.as(ExtensionContextDescriptor.self).extendedContext
            // Demangle the extension self type.
            var selfType = demangler.demangleType(
                mangledName: extendedContext,
                resolver: resolveToDemanglingForContext(in: demangler)
            ).unsafelyUnwrapped
            if selfType.kind == .type {
                selfType = selfType.child(at: 0)
            }
            // Substitute in the generic arguments.
            let argsList = genericArgsTypeList(for: context)
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
            assert(node != nil)
            extNode.appendChild(any: node, in: demangler)
            extNode.appendChild(selfType, in: demangler)
            // TODO: Turn the generic signature into a demangling as the third
            // generic argument.
            node = extNode
        case .protocol:
            fallthrough
        default:
            fatalError()
        }
    }
    fatalError("invalid symbolic reference kind")
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
