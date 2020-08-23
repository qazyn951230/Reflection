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

#include <swift/Runtime/ExistentialContainer.h>
#include "runtime/Private.h"
#include "include/CReflection.h"

SP_SIMPLE_CONVERSION(swift::Demangle::Demangler, demangler_p)
SP_SIMPLE_CONVERSION(swift::Demangle::Node, dnode_p)

using namespace swift;
using namespace swift::Demangle;

dnode_p build_demangling_for_metadata(const void* metadata) {
    Demangler demangler;
    auto node = _swift_buildDemanglingForMetadata(reinterpret_cast<const Metadata*>(metadata), demangler);
    return wrap(node);
}

dnode_p build_demangling_for_metadata_in(const void* metadata, demangler_p demangler) {
    auto& _demangler = *unwrap(demangler);
    auto node = _swift_buildDemanglingForMetadata(reinterpret_cast<const Metadata*>(metadata),
        _demangler);
    return wrap(node);
}

TypeInfo getTypeByMangledName(const Metadata* metadata, const char* name, size_t length) {
    StringRef typeName{name, length};
    SubstGenericParametersFromMetadata substitutions(metadata);
    return swift_getTypeByMangledName(
        MetadataState::Complete,
        typeName,
        substitutions.getGenericArgs(),
        [&substitutions](unsigned depth, unsigned index) {
            return substitutions.getMetadata(depth, index);
        }, [&substitutions](const Metadata* type, unsigned index) {
            return substitutions.getWitnessTable(type, index);
        });
}

void getTypeByMangledName(const char* name, size_t length, const void* metadata, CRTypeInfo* result) {
    auto base = reinterpret_cast<const Metadata*>(metadata);
    const auto& info = getTypeByMangledName(base, name, length);
    if (result != nullptr) {
        result->isWeak = info.isWeak();
        result->isUnmanaged = info.isUnmanaged();
        result->isUnowned = info.isUnowned();
        result->metadata = info.getMetadata();
    }
}

// The layout of Any.
using Any = OpaqueExistentialContainer;

// Swift assumes Any is returned in memory.
// Use AnyReturn to guarantee that even on architectures
// where Any would be returned in registers.
struct AnyReturn {
    Any any;
    explicit AnyReturn(Any value): any(value) {}
    // Empty destructor ✅, default destructor ❎
    ~AnyReturn() {}

    explicit operator Any() const { return any; }
};

// We intentionally use a non-POD return type with this entry point to give
// it an indirect return ABI for compatibility with Swift.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreturn-type-c-linkage"

// @_silgen_name("copyStructField")
// func copyStructField<T>(metadata: UnsafePointer<StructMetadata.RawValue>, name: UnsafePointer<Int8>,
//                         length: Int, fieldOffset: UInt32, value: T) -> Any
SWIFT_CC(swift)
extern "C" AnyReturn copyStructField(const StructMetadata* metadata, const char* name, size_t length,
                                     uint32_t fieldOffset, const void* value) {
    assert(metadata->getKind() == MetadataKind::Struct);
    const auto& info = getTypeByMangledName(metadata, name, length);
    Any result;
    result.Type = info.getMetadata();
    auto address = result.Type->allocateBoxForExistentialIn(&result.Buffer);
    auto *bytes = reinterpret_cast<const char*>(value);
    auto fieldData = reinterpret_cast<const OpaqueValue *>(bytes + fieldOffset);
    result.Type->vw_initializeWithCopy(address, const_cast<OpaqueValue *>(fieldData));
    return AnyReturn(result);
}
#pragma clang diagnostic pop
