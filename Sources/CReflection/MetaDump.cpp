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

#if DEBUG

#include <iostream>
#include "MetaDump.hpp"

using namespace swift;

namespace MetaDump {

const char* metadataKindText(MetadataKind kind);
const char* descriptionKindText(ContextDescriptorKind kind);

void dump(const StructMetadata* metadata) {
    auto descriptor = metadata->getDescription();
    const char* name = descriptor->Name;
    std::cout << name << "\n";
}

void dump(const Metadata* metadata, const Options& options) {
    if (options.type()) {
        auto kind = metadata->getKind();
        std::cout << metadataKindText(kind) <<
            "(0x" << std::hex << static_cast<uint32_t>(kind) << ")";
    }
    if (options.address()) {
        std::cout << " (" << metadata << ")\n";
    } else {
        std::cout << "\n";
    }
    if (options.name()) {
        switch (metadata->getKind()) {
            case MetadataKind::Struct:
                dump(reinterpret_cast<const StructMetadata*>(metadata));
                break;
            default:
                break;
        }
    }
    std::cout.flush();
}

void basic(const Metadata* metadata) {
    Options options;
    dump(metadata, options.dumpName()
            .dumpAddress()
            .dumpType());
}

const char* metadataKindText(MetadataKind kind) {
    switch (kind) {
        case MetadataKind::Class:
            return "MetadataKind::Class";
        case MetadataKind::Struct:
            return "MetadataKind::Struct";
        case MetadataKind::Enum:
            return "MetadataKind::Enum";
        case MetadataKind::Optional:
            return "MetadataKind::Optional";
        case MetadataKind::ForeignClass:
            return "MetadataKind::ForeignClass";
        case MetadataKind::Opaque:
            return "MetadataKind::Opaque";
        case MetadataKind::Tuple:
            return "MetadataKind::Tuple";
        case MetadataKind::Function:
            return "MetadataKind::Function";
        case MetadataKind::Existential:
            return "MetadataKind::Existential";
        case MetadataKind::Metatype:
            return "MetadataKind::Metatype";
        case MetadataKind::ObjCClassWrapper:
            return "MetadataKind::ObjCClassWrapper";
        case MetadataKind::ExistentialMetatype:
            return "MetadataKind::ExistentialMetatype";
        case MetadataKind::HeapLocalVariable:
            return "MetadataKind::HeapLocalVariable";
        case MetadataKind::HeapGenericLocalVariable:
            return "MetadataKind::HeapGenericLocalVariable";
        case MetadataKind::ErrorObject:
            return "MetadataKind::ErrorObject";
        default:
            return "MetadataKind::Unknown";
    }
}

const char* descriptionKindText(ContextDescriptorKind kind) {
    switch (kind) {
        case ContextDescriptorKind::Module:
            return "ContextDescriptorKind::Module(0)";
        case ContextDescriptorKind::Extension:
            return "ContextDescriptorKind::Extension(1)";
        case ContextDescriptorKind::Anonymous:
            return "ContextDescriptorKind::Anonymous(2)";
        case ContextDescriptorKind::Protocol:
            return "ContextDescriptorKind::Protocol(3)";
        case ContextDescriptorKind::OpaqueType:
            return "ContextDescriptorKind::OpaqueType(4)";
        case ContextDescriptorKind::Class:
            return "ContextDescriptorKind::Class(16)";
        case ContextDescriptorKind::Struct:
            return "ContextDescriptorKind::Struct(17)";
        case ContextDescriptorKind::Enum:
            return "ContextDescriptorKind::Enum(18)";
        default:
            return "ContextDescriptorKind::Unknown";
    }
}

}

#endif // DEBUG
