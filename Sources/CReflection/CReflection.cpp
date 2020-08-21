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

void getTypeByMangledName(const char* name, size_t length, const void* metadata, CRTypeInfo* result) {
    StringRef typeName{name, length};
    auto base = reinterpret_cast<const Metadata*>(metadata);
    SubstGenericParametersFromMetadata substitutions(base);
    const auto& info = swift_getTypeByMangledName(
        MetadataState::Complete,
        typeName,
        substitutions.getGenericArgs(),
        [&substitutions](unsigned depth, unsigned index) {
            return substitutions.getMetadata(depth, index);
        }, [&substitutions](const Metadata* type, unsigned index) {
            return substitutions.getWitnessTable(type, index);
        });
    if (result != nullptr) {
        result->isWeak = info.isWeak();
        result->isUnmanaged = info.isUnmanaged();
        result->isUnowned = info.isUnowned();
        result->metadata = info.getMetadata();
    }
}
