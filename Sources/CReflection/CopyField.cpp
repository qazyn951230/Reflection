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
#include <swift/Runtime/HeapObject.h>

#if SWIFT_OBJC_INTEROP
#include <objc/Object.h>
#endif

#include "runtime/WeakReference.h"
#include "runtime/Private.h"
#include "MetaDump.hpp"
#include "CReflection.hpp"

using namespace swift;

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

static void copyWeakField(const OpaqueValue* data, const TypeInfo& info, Any& result) {
    assert(info.isWeak());
    auto metadata = info.getMetadata();
    assert(metadata->getKind() == MetadataKind::Optional);
    auto weakData = reinterpret_cast<const WeakReference*>(data);
    auto strongData = swift_unknownObjectWeakLoadStrong(const_cast<WeakReference*>(weakData));

    // Now that we have a strong reference, we need to create a temporary buffer
    // from which to copy the whole value, which might be a native class-bound
    // existential, which means we also need to copy n witness tables, for
    // however many protocols are in the protocol composition. For example, if we
    // are copying a:
    // weak var myWeakProperty : (Protocol1 & Protocol2)?
    // then we need to copy three values:
    // - the instance
    // - the witness table for Protocol1
    // - the witness table for Protocol2

    auto weakContainer = reinterpret_cast<const WeakClassExistentialContainer*>(data);

    // Create a temporary existential where we can put the strong reference.
    // The allocateBuffer value witness requires a ValueBuffer to own the
    // allocated storage.
    ValueBuffer buffer;
    auto value = reinterpret_cast<ClassExistentialContainer*>(metadata->allocateBufferIn(&buffer));

    // Now copy the entire value out of the parent, which will include the
    // witness tables.
    value->Value = strongData;
    size_t size = metadata->getValueWitnesses()->getSize() - sizeof(WeakClassExistentialContainer);
    ::memcpy(value->getWitnessTables(), weakContainer->getWitnessTables(), size);

    result.Type = metadata;
    auto address = result.Type->allocateBoxForExistentialIn(&result.Buffer);
    metadata->vw_initializeWithCopy(address, reinterpret_cast<OpaqueValue *>(value));
    metadata->deallocateBufferIn(&buffer);
    swift_unknownObjectRelease(strongData);
}

//static std::tuple<const Metadata*, const OpaqueValue*> resolve(const ClassMetadata* metadata,
//    const Metadata* tType, const OpaqueValue* value) {
//    // If the value is an existential container, look through it to reflect the
//    // contained value.
//    // TODO: Should look through existential metatypes too, but it doesn't
//    // really matter yet since we don't have any special mirror behavior for
//    // concrete metatypes yet.
//    while (tType->getKind() == MetadataKind::Existential) {
//        auto existential = reinterpret_cast<const ExistentialTypeMetadata*>(tType);
//        // Unwrap the existential container.
//        tType = existential->getDynamicType(value);
//        value = existential->projectValue(value);
//
//        // Existential containers can end up nested in some cases due to generic
//        // abstraction barriers.  Repeat in case we have a nested existential.
//    }
//    return std::make_tuple(value != nullptr ? metadata : tType, value);
//}

// We intentionally use a non-POD return type with this entry point to give
// it an indirect return ABI for compatibility with Swift.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreturn-type-c-linkage"

// @_silgen_name("copy_struct_field")
// func copyStructField(metadata: UnsafePointer<StructMetadata.RawValue>, name: UnsafePointer<Int8>,
//                      fieldOffset: UInt32, value: Any) -> Any
SWIFT_CC(swift)
extern "C" AnyReturn copy_struct_field(const StructMetadata* metadata, const char* name,
    uint32_t fieldOffset, const OpaqueValue* value) {
    assert(StructMetadata::classof(metadata));
    const auto& info = getTypeByMangledName(metadata, name);
    auto bytes = reinterpret_cast<const char*>(value);
    auto fieldData = reinterpret_cast<const OpaqueValue *>(bytes + fieldOffset);

    Any result;
    if (info.isWeak()) {
        copyWeakField(fieldData, info, result);
    } else {
        result.Type = info.getMetadata();
        auto address = result.Type->allocateBoxForExistentialIn(&result.Buffer);
        result.Type->vw_initializeWithCopy(address, const_cast<OpaqueValue *>(fieldData));
    }
    return AnyReturn(result);
}

// @_silgen_name("copy_enum_field")
// func copyEnumField(metadata: UnsafePointer<EnumMetadata.RawValue>, name: UnsafePointer<Int8>,
//                    indirect: Bool, value: Any) -> Any
SWIFT_CC(swift)
extern "C" AnyReturn copy_enum_field(const EnumMetadata* metadata, const char* name,
    bool indirect, const OpaqueValue* value) {
    assert(EnumMetadata::classof(metadata));
    const auto& info = getTypeByMangledName(metadata, name);
    auto payloadType = info.getMetadata();

    // Copy the enum payload into a box
    const Metadata* boxType = indirect ? &METADATA_SYM(Bo).base : payloadType;
    BoxPair box = swift_allocBox(boxType);
    metadata->vw_destructiveProjectEnumData(const_cast<OpaqueValue*>(value));
    boxType->vw_initializeWithCopy(box.buffer, const_cast<OpaqueValue*>(value));

    // 'tag' is in the range [0..NumElements-1].
    unsigned tag = metadata->vw_getEnumTag(value);
    metadata->vw_destructiveInjectEnumTag(const_cast<OpaqueValue*>(value), tag);

    auto _value = box.buffer;
    // If the payload is indirect, we need to jump through the box to get it.
    if (indirect) {
        const HeapObject* owner = *reinterpret_cast<HeapObject* const*>(value);
        _value = swift_projectBox(const_cast<HeapObject*>(owner));
    }

    Any result;
    result.Type = payloadType;
    auto address = result.Type->allocateBoxForExistentialIn(&result.Buffer);
    result.Type->vw_initializeWithCopy(address, _value);

    swift_release(box.object);
    return AnyReturn(result);
}

// @_silgen_name("copy_class_field")
// func copyClassField(metadata: UnsafePointer<ClassMetadata.RawValue>, name: UnsafePointer<Int8>,
//                     index: Int, value: Any) -> Any
SWIFT_CC(swift)
extern "C" AnyReturn copy_class_field(const ClassMetadata* metadata, const char* name,
    size_t index, const OpaqueValue* value) {
    assert(ClassMetadata::classof(metadata));
    assert(index >= 0 && index < metadata->getDescription()->NumFields);
    // FIXME: If the class has ObjC heritage, get the field offset using the ObjC
    // metadata, because we don't update the field offsets in the face of
    // resilient base classes.
    uint32_t fieldOffset;
    if (usesNativeSwiftReferenceCounting(metadata)) {
        fieldOffset = metadata->getFieldOffsets()[index];
    } else {
#if SWIFT_OBJC_INTEROP
        auto clazz = const_cast<ClassMetadata *>(metadata);
        auto ivars = class_copyIvarList(reinterpret_cast<Class>(clazz), nullptr);
        fieldOffset = ivar_getOffset(ivars[index]);
        free(ivars);
#else
        assert(false && "Object appears to be Objective-C, but no runtime.");
#endif
    }

    const auto& info = getTypeByMangledName(metadata, name);
    auto bytes = reinterpret_cast<const char*>(value);
    auto fieldData = reinterpret_cast<const OpaqueValue *>(bytes + fieldOffset);

    Any result;
    if (info.isWeak()) {
        copyWeakField(fieldData, info, result);
    } else {
        result.Type = info.getMetadata();
        auto address = result.Type->allocateBoxForExistentialIn(&result.Buffer);
        result.Type->vw_initializeWithCopy(address, const_cast<OpaqueValue *>(fieldData));
    }
    return AnyReturn(result);
}
#pragma clang diagnostic pop
