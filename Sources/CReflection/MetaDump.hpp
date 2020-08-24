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

#ifndef REFLECTION_META_DUMP_HPP
#define REFLECTION_META_DUMP_HPP

#if DEBUG

#include <swift/ABI/Metadata.h>
#include <swift/Basic/FlagSet.h>

#define FLAGSET_DEFINE_FLAG_ACCESSORS_THIS(BIT, GETTER, SETTER, THIS)   \
  bool GETTER() const {                                                 \
    return this->template getFlag<BIT>();                               \
  }                                                                     \
  THIS& SETTER(bool value = true) noexcept {                            \
    this->template setFlag<BIT>(value);                                 \
    return *this;                                                       \
  }                                                                     \

namespace MetaDump {

class Options final : private swift::FlagSet<uint32_t> {
public:
    using super = swift::FlagSet<uint32_t>;

    Options() noexcept: super() {}

    ~Options() = default;

    FLAGSET_DEFINE_FLAG_ACCESSORS_THIS(0, name, dumpName, Options)
    FLAGSET_DEFINE_FLAG_ACCESSORS_THIS(1, address, dumpAddress, Options)
    FLAGSET_DEFINE_FLAG_ACCESSORS_THIS(2, type, dumpType, Options)
};

void dump(const swift::Metadata* metadata, const Options& options);
void basic(const swift::Metadata* metadata);
}

#endif // DEBUG

#endif // REFLECTION_META_DUMP_HPP
