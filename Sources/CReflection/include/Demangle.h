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

#ifndef REFLECTION_DEMANGLE_H
#define REFLECTION_DEMANGLE_H

#if !__has_feature(blocks)
#error -fblocks is a requirement to use this library
#endif

#include "Types.h"
#include "CRDNodeKind.h"

SP_C_FILE_BEGIN

/// Kinds of symbolic reference supported.
typedef SP_ENUM(uint8_t, CRSymbolicReferenceKind) {
    /// A symbolic reference to a context descriptor, representing the
    /// (unapplied generic) context.
    CRSymbolicReferenceKindContext,
    /// A symbolic reference to an accessor function, which can be executed in
    /// the process to get a pointer to the referenced entity.
    CRSymbolicReferenceKindAccessorFunctionReference,
};

typedef SP_ENUM(int, CRDirectness) {
    CRDirectnessDirect,
    CRDirectnessIndirect,
};

typedef dnode_p SP_NULLABLE (^symbolic_resolver_t)(CRSymbolicReferenceKind, const void*);
typedef dnode_p SP_NULLABLE (^symbolic_reference_resolver_t)(CRSymbolicReferenceKind,
    CRDirectness, int32_t, const void*);
typedef void (^remangle_text_t)(const char*, size_t);

demangler_p demangler_create();
void demangler_free(demangler_p ref);

void demangler_clear(demangler_p demangler);

dnode_p SP_NULLABLE demangler_demangle_type(demangler_p demangler,
    const uint8_t* mangledName, NSUInteger length);
dnode_p SP_NULLABLE demangler_demangle_type_block(demangler_p demangler, const uint8_t* mangledName,
    NSUInteger length, symbolic_reference_resolver_t SP_NOESCAPE resolver);

dnode_p demangler_create_node(demangler_p demangler, CRDNodeKind kind);
dnode_p demangler_create_node_index(demangler_p demangler, CRDNodeKind kind, NSUInteger pointer);

CRDNodeKind dnode_get_kind(dnode_p node);
uint64_t dnode_get_index(dnode_p node);
const char* dnode_get_text(dnode_p node, NSInteger* SP_NULLABLE length);
size_t dnode_children_count(dnode_p node);
dnode_p dnode_child_at_index(dnode_p node, size_t index);
void dnode_append_child(dnode_p node, dnode_p child, demangler_p demangler);

bool dnode_is_text_equals(dnode_p node, const char* text);

bool dnode_is_specialized(dnode_p node);
dnode_p dnode_get_unspecialized(dnode_p node, demangler_p demangler);

void remangle_node(dnode_p node, remangle_text_t SP_NOESCAPE text);
void remangle_node_block(dnode_p node, symbolic_resolver_t SP_NOESCAPE resolver,
    remangle_text_t SP_NOESCAPE text);
void remangle_node_factory(dnode_p node, symbolic_resolver_t SP_NOESCAPE resolver,
    demangler_p demangler, remangle_text_t SP_NOESCAPE text);

SP_C_FILE_END

#endif //REFLECTION_DEMANGLE_H
