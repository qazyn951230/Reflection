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

#include <swift/Demangling/Demangler.h>
#include "include/Demangle.h"
#include "Types.hpp"

using namespace swift;
using namespace swift::Demangle;

demangler_p demangler_create() {
    return wrap(new Demangler);
}

void demangler_free(demangler_p ref) {
    delete unwrap(ref);
}

void demangler_clear(demangler_p demangler) {
    unwrap(demangler)->clear();
}

dnode_p demangler_demangle_type(demangler_p demangler, const uint8_t* mangledName, NSUInteger length) {
    StringRef name{reinterpret_cast<const char*>(mangledName), static_cast<size_t>(length)};
    auto node = unwrap(demangler)->demangleType(name);
    return reinterpret_cast<dnode_p>(node);
}

dnode_p demangler_demangle_type_block(demangler_p demangler, const uint8_t* mangledName,
    NSUInteger length, symbolic_reference_resolver_t SP_NOESCAPE resolver) {
    StringRef name{reinterpret_cast<const char*>(mangledName), static_cast<size_t>(length)};
    auto node = unwrap(demangler)->demangleType(name, [&](SymbolicReferenceKind a, Directness b, auto c, auto d) {
        auto node = resolver(static_cast<CRSymbolicReferenceKind>(a), static_cast<CRDirectness>(b), c, d);
        return reinterpret_cast<NodePointer>(node);
    });
    return reinterpret_cast<dnode_p>(node);
}

dnode_p demangler_create_node(demangler_p demangler, CRDNodeKind kind) {
    return wrap(unwrap(demangler)->createNode(static_cast<Node::Kind>(kind)));
}

dnode_p demangler_create_node_index(demangler_p demangler, CRDNodeKind kind, NSUInteger pointer) {
    return wrap(unwrap(demangler)->createNode(static_cast<Node::Kind>(kind), static_cast<uint64_t>(pointer)));
}

CRDNodeKind dnode_get_kind(dnode_p node) {
    return static_cast<CRDNodeKind>(unwrap(node)->getKind());
}

uint64_t dnode_get_index(dnode_p node) {
    return unwrap(node)->getIndex();
}

const char* dnode_get_text(dnode_p node, NSInteger* SP_NULLABLE length) {
    const auto& text = unwrap(node)->getText();
    if (length != nullptr) {
        *length = text.size();
    }
    return text.data();
}

size_t dnode_children_count(dnode_p node) {
    return unwrap(node)->getNumChildren();
}

dnode_p dnode_child_at_index(dnode_p node, size_t index) {
    return wrap(unwrap(node)->getChild(index));
}

void dnode_append_child(dnode_p node, dnode_p child, demangler_p demangler) {
    unwrap(node)->addChild(unwrap(child), *unwrap(demangler));
}

bool dnode_is_text_equals(dnode_p node, const char* text) {
    return unwrap(node)->getText().equals(text);
}

bool dnode_is_specialized(dnode_p node) {
    return ::isSpecialized(unwrap(node));
}

dnode_p dnode_get_unspecialized(dnode_p node, demangler_p demangler) {
    return wrap(::getUnspecialized(unwrap(node), *unwrap(demangler)));
}
