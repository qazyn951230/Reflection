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

class Demangler {
    let ref: demangler_p

    init() {
        ref = demangler_create()
    }

    deinit {
        demangler_free(ref)
    }

    @discardableResult
    func createNode(kind: DNodeKind) -> DNodeRef {
        DNodeRef(ref: demangler_create_node(ref, kind))
    }
}

struct DNodeRef {
    let ref: dnode_p
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

    static func gatherWrittenGenericArgs<Descriptor>(
        metadata: AnyMetadata, description: Descriptor, demangler: Demangler
    ) -> [Metadata?] where Descriptor: TargetGenericContainer {
        // .../include/swift/ABI/Metadata.h!TargetTypeContextDescriptor<InProcess>::getGenericContext
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
            return result
        }
        return result
    }
}

#endif // ENABLE_REFLECTION_DEMANGLE
