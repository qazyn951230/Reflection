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

struct DNodeRef {
    let ref: dnode_p

    @inlinable
    func appendChild(_ child: DNodeRef, in demangler: Demangler) {
        dnode_append_child(ref, child.ref, demangler.ref)
    }

    @inlinable
    func appendChild(any child: DNodeRef?, in demangler: Demangler) {
        guard let t = child?.ref else {
            return
        }
        dnode_append_child(ref, t, demangler.ref)
    }

    @inlinable
    var kind: DNodeKind {
        dnode_get_kind(ref)
    }

    @inlinable
    var childCount: Int {
        dnode_children_count(ref)
    }

    @inlinable
    var isSpecialized: Bool {
        dnode_is_specialized(ref)
    }

    @inlinable
    var index: UInt64 {
        dnode_get_index(ref)
    }

    @inlinable
    var text: String {
        String(cString: dnode_get_text(ref, nil))
    }

    @inlinable
    func unspecialized(in demangler: Demangler) -> DNodeRef {
        DNodeRef(ref: dnode_get_unspecialized(ref, demangler.ref))
    }

    @inlinable
    func child(at index: Int) -> DNodeRef {
        DNodeRef(ref: dnode_child_at_index(ref, index))
    }

    @inlinable
    func textEquals(_ value: String) -> Bool {
        dnode_is_text_equals(ref, value)
    }

    @inlinable
    subscript(index: Int) -> DNodeRef {
        child(at: index)
    }
}

#endif // ENABLE_REFLECTION_DEMANGLE
