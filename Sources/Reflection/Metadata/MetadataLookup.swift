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

// .../swift/stdlib/public/runtime/MetadataLookup.cpp

// swift::gatherWrittenGenericArgs
func gatherWrittenGenericArgs<Descriptor>(
    metadata: AnyMetadata, description: Descriptor, demangler: Demangler
) -> [Metadata?] where Descriptor: TargetGenericContainer {
    guard let generics = description.genericContext(),
        let parameters = generics.genericParameters() else {
        return []
    }
    var missingWrittenArguments = false
    var result: [Metadata?] = []
    var args = description.genericArguments(of: metadata)
    for parameter in parameters {
        if parameter.kind == .type {
            if parameter.contains(.keyArgument) {
                let arg = args.pointee
                args += 1
                result.append(Metadata(rawValue: arg))
            } else {
                result.append(nil)
                missingWrittenArguments = true
            }
            if parameter.contains(.extraArgument) {
                result.append(nil)
                args += 1
            }
        } else {
            if parameter.contains(.keyArgument) {
                result.append(nil)
                args += 1
            }
            if parameter.contains(.extraArgument) {
                result.append(nil)
                args += 1
            }
        }
    }
    guard missingWrittenArguments else {
        // If there is no follow-up work to do, we're done.
        return result
    }
    // We have generic arguments that would be written, but have been
    // canonicalized away. Use same-type requirements to reconstitute them.

    // Retrieve the mapping information needed for depth/index -> flat index.
    return result
}

// swift::_gatherGenericParameterCounts
func gatherGenericParameterCounts<Descriptor>(
    descriptor: Descriptor, demangler: Demangler
) -> [UInt32] where Descriptor: TargetGenericContainer {
    return []
}

// _findExtendedTypeContextDescriptor
func findExtendedTypeContextDescriptor(
    descriptor: ContextDescriptor, in demangler: Demangler
) -> ContextDescriptor? {
    guard case .extension = descriptor.kind else {
        return nil
    }
    let ext = descriptor.as(ExtensionContextDescriptor.self)
    let _node = demangler.demangleType(mangledName: ext.extendedContext,
                                       resolver: resolveAsSymbolicReference(demangler: demangler))
    guard var node = _node else {
        return nil
    }
    if case .type = node.kind {
        if node.childCount < 1 {
            return nil
        }
        node = node.child(at: 0)
    }
    if node.isSpecialized {
        node = node.unspecialized(in: demangler)
    }
    return findContextDescriptor(node: node, in: demangler)
}

// _findContextDescriptor
func findContextDescriptor(node: DNodeRef, in demangler: Demangler) -> ContextDescriptor? {
    var symbolicNode = node
    if symbolicNode.kind == .type {
        symbolicNode = symbolicNode.child(at: 0)
    }
    // If we have a symbolic reference to a context, resolve it immediately.
    if symbolicNode.kind == .typeSymbolicReference {
        return ContextDescriptor.cast(from:
            UnsafeRawPointer(bitPattern: UInt(node.index)).unsafelyUnwrapped)
    }
    // Fast-path lookup for standard library type references with short manglings.
    if symbolicNode.childCount >= 2 {
        let first = symbolicNode.child(at: 0)
        let second = symbolicNode.child(at: 1)
        if first.kind == .module && first.textEquals("Swift") && second.kind == .type {
            var length = 0
            let name = dnode_get_text(second.ref, &length)
            return ContextDescriptor.cast(from: find_standard_type_descriptor(name, length))
        }
    }
    // Nothing to resolve if have a generic parameter.
    if symbolicNode.kind == .dependentGenericParamType {
        return nil
    }
    return nil
}

// swift_getTypeByMangledNameImpl
// func resolveType(byMangledName name: String) {}

#endif // ENABLE_REFLECTION_DEMANGLE
