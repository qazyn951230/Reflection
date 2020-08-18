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

using namespace swift::Demangle;

void remangle_node(dnode_p node, remangle_text_t SP_NOESCAPE text) {
    const auto& name = ::mangleNode(unwrap(node));
    text(name.data(), name.length());
}

void remangle_node_block(dnode_p node, symbolic_resolver_t SP_NOESCAPE resolver,
    remangle_text_t SP_NOESCAPE text) {
    const auto& name = ::mangleNode(unwrap(node), [&](SymbolicReferenceKind a, auto b) {
        return reinterpret_cast<NodePointer>(resolver(static_cast<CRSymbolicReferenceKind>(a), b));
    });
    text(name.data(), name.length());
}

void remangle_node_factory(dnode_p node, symbolic_resolver_t SP_NOESCAPE resolver,
    demangler_p demangler, remangle_text_t SP_NOESCAPE text) {
    const auto& name = ::mangleNode(unwrap(node), [&](SymbolicReferenceKind a, auto b) {
        return reinterpret_cast<NodePointer>(resolver(static_cast<CRSymbolicReferenceKind>(a), b));
    }, *unwrap(demangler));
    text(name.data(), name.size());
}
