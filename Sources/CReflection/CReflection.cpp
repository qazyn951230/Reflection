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

#include "runtime/Private.h"
#include "include/CReflection.h"
#include "CReflection.hpp"

SP_SIMPLE_CONVERSION(swift::Demangle::Demangler, demangler_p)
SP_SIMPLE_CONVERSION(swift::Demangle::Node, dnode_p)

using namespace swift;
using namespace swift::Demangle;

dnode_p build_demangling_for_metadata(const void* metadata) {
    Demangler demangler;
    auto node = _swift_buildDemanglingForMetadata(
        reinterpret_cast<const Metadata*>(metadata), demangler);
    return wrap(node);
}

dnode_p build_demangling_for_metadata_in(const void* metadata,
    demangler_p demangler) {
    auto& _demangler = *unwrap(demangler);
    auto node = _swift_buildDemanglingForMetadata(
        reinterpret_cast<const Metadata*>(metadata), _demangler);
    return wrap(node);
}

llvm::StringRef makeMangledNameRef(const char* base) {
    if (!base) {
        return {};
    }

    auto end = base;
    while (*end != '\0') {
        // Skip over symbolic references.
        if (*end >= '\x01' && *end <= '\x17') {
            end += sizeof(uint32_t);
        } else if (*end >= '\x18' && *end <= '\x1F') {
            end += sizeof(void*);
        }
        ++end;
    }
    return llvm::StringRef(base, end - base);
}

TypeInfo getTypeByMangledName(const Metadata* metadata, const StringRef& name) {
    SubstGenericParametersFromMetadata substitutions(metadata);
    return swift_getTypeByMangledName(
        MetadataState::Complete, name, substitutions.getGenericArgs(),
        [&substitutions](unsigned depth, unsigned index) {
            return substitutions.getMetadata(depth, index);
        },
        [&substitutions](const Metadata* type, unsigned index) {
            return substitutions.getWitnessTable(type, index);
        });
}

void get_type_by_mangled_name(const uint8_t* name, const void* metadata, CRTypeInfo* result) {
    if (result == nullptr) {
        return;
    }

    auto base = reinterpret_cast<const Metadata*>(metadata);
    const auto& info = getTypeByMangledName(base, reinterpret_cast<const char*>(name));
    result->isWeak = info.isWeak();
    result->isUnmanaged = info.isUnmanaged();
    result->isUnowned = info.isUnowned();
    result->metadata = info.getMetadata();
}

// runtime/MetadataLookup.cpp!swift_getTypeByMangledNameInContext
const void* SP_NULLABLE get_type_by_mangled_name_in_context(const uint8_t* name,
    const void* SP_NULLABLE context, const void* SP_NULLABLE arguments) {
    const auto& typeName = makeMangledNameRef(reinterpret_cast<const char*>(name));
    SubstGenericParametersFromMetadata substitutions{
        reinterpret_cast<const TargetContextDescriptor<InProcess>*>(context),
        reinterpret_cast<const void* const*>(arguments)
    };
    const auto& info = swift_getTypeByMangledName(MetadataState::Complete, typeName,
        reinterpret_cast<const void* const*>(arguments),
        [&substitutions](unsigned depth, unsigned index) {
            return substitutions.getMetadata(depth, index);
        },
        [&substitutions](const Metadata* type, unsigned index) {
            return substitutions.getWitnessTable(type, index);
        });
    return info.getMetadata();
}
