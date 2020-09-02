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

#ifndef REFLECTION_REFLECTION_MIRROR_HPP
#define REFLECTION_REFLECTION_MIRROR_HPP

#if DEBUG_MIRROR

#include <swift/Runtime/ExistentialContainer.h>

// The layout of Any.
using Any = swift::OpaqueExistentialContainer;

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

static std::tuple<const swift::Metadata*, swift::OpaqueValue*>
unwrapExistential(const swift::Metadata* T, swift::OpaqueValue* Value);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreturn-type-c-linkage"

SWIFT_CC(swift)
extern "C" [[maybe_unused]] AnyReturn
swift_reflectionMirror_subscript(swift::OpaqueValue * value, const swift::Metadata* type,
    intptr_t index, const char** outName, void (** outFreeFunc)(const char*),
    const swift::Metadata* T);

#pragma clang diagnostic pop

#endif

#endif // REFLECTION_REFLECTION_MIRROR_HPP
