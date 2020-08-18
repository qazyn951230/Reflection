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

#include <llvm/ADT/StringRef.h>
#include <swift/Runtime/Debug.h>
#include "include/MetadataLookup.h"

#define DESCRIPTOR_MANGLING_SUFFIX_Structure Mn
#define DESCRIPTOR_MANGLING_SUFFIX_Enum Mn
#define DESCRIPTOR_MANGLING_SUFFIX_Protocol Mp

#define DESCRIPTOR_MANGLING_SUFFIX_(X) X
#define DESCRIPTOR_MANGLING_SUFFIX(KIND) \
  DESCRIPTOR_MANGLING_SUFFIX_(DESCRIPTOR_MANGLING_SUFFIX_ ## KIND)

#define DESCRIPTOR_MANGLING_(CHAR, SUFFIX) \
  $sS ## CHAR ## SUFFIX
#define DESCRIPTOR_MANGLING(CHAR, SUFFIX) DESCRIPTOR_MANGLING_(CHAR, SUFFIX)

#define STANDARD_TYPE(KIND, MANGLING, TYPENAME) \
  extern "C" const void* DESCRIPTOR_MANGLING(MANGLING, DESCRIPTOR_MANGLING_SUFFIX(KIND));

#if !SWIFT_OBJC_INTEROP
# define OBJC_INTEROP_STANDARD_TYPE(KIND, MANGLING, TYPENAME)
#endif

#include "swift/Demangling/StandardTypesMangling.def"

const void* find_standard_type_descriptor(const char* name, size_t length) {
    llvm::StringRef _name{name, length};

#define STANDARD_TYPE(KIND, MANGLING, TYPENAME) \
    if (_name.equals(#TYPENAME)) { \
      return &DESCRIPTOR_MANGLING(MANGLING, DESCRIPTOR_MANGLING_SUFFIX(KIND)); \
    }
#if !SWIFT_OBJC_INTEROP
# define OBJC_INTEROP_STANDARD_TYPE(KIND, MANGLING, TYPENAME)
#endif

#include "swift/Demangling/StandardTypesMangling.def"

    swift::fatalError(0, "%s is not standard type", name);
}
