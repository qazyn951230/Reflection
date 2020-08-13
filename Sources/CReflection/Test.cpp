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

#include <swift/Runtime/Metadata.h>
#include <swift/ABI/MetadataValues.h>
#include <iostream>
#include "include/Test.h"

using namespace swift;

const char* metadataKindText(MetadataKind kind);

const char* descriptionKindText(ContextDescriptorKind kind);

void printMetadataName(const Metadata* metadata);

void printAllDescriptionKind(const ContextDescriptor* description);

void test_print_all_kind(const void* value) {
    auto metadata = reinterpret_cast<const Metadata*>(value);
    auto kind = metadata->getKind();
    std::cout << metadataKindText(kind) << "(0x" << std::hex << static_cast<uint32_t>(kind) << ")\n";
    switch (kind) {
        case MetadataKind::Class:
            printAllDescriptionKind(reinterpret_cast<const ClassMetadata*>(metadata)->getDescription());
            break;
        case MetadataKind::Struct:
            printAllDescriptionKind(reinterpret_cast<const StructMetadata*>(metadata)->getDescription());
            break;
        default:
            break;
    }
    std::cout << std::flush;
}

void test_print_generic_context(const void* value) {
    auto metadata = reinterpret_cast<const StructMetadata*>(value);
    if (metadata->getKind() != MetadataKind::Struct) {
        return;
    }
    auto description = metadata->getDescription();
//    std::cout << "description-> " << description << "\n";
    if (!description->isGeneric()) {
        std::cout << "Not generic type\n";
        return;
    }
//    auto& header = description->getGenericContextHeader();
//    std::cout << "header-> " << &header << "\n";
//    std::cout << header.NumParams << ", " <<
//        header.NumRequirements << ", " <<
//        header.NumKeyArguments << ", " <<
//        header.NumExtraArguments;
    auto generics = description->getGenericContext();
    std::cout << "genericContext-> " << generics << "\n";
    auto genericArgs = description->getGenericArguments(metadata);
    std::cout << "genericArgs-> " << genericArgs << "\n";
    for (auto& param: generics->getGenericParams()) {
        std::cout << static_cast<uint32_t>(param.getKind()) << "\n";
        if (param.getKind() == GenericParamKind::Type) {
            printMetadataName(*genericArgs);
        }
        genericArgs += 1;
    }
    std::cout << std::flush;
}

void test_print_properties(const void* value) {
    using namespace reflection;

    auto metadata = reinterpret_cast<const StructMetadata*>(value);
    if (metadata->getKind() != MetadataKind::Struct ||
        !metadata->getDescription()->isReflectable()) {
        return;
    }
    const FieldDescriptor* fields = metadata->getDescription()->Fields;
    auto records = fields->getFields();
    auto offsets = metadata->getFieldOffsets();
    std::cout << "metadata-> " << metadata << "\n" <<
              "fields-> " << fields << "\n" <<
              "records-> " << records.data() << "\n" <<
        "offsets-> " << offsets << "\n";
    
    for (auto& record: records) {
        std::cout << &record << "\n" << "offset-> " << *offsets << "\n";
        offsets += 1;
    }
    std::cout << std::flush;
}

void printAllDescriptionKind(const ContextDescriptor* description) {
    while (description != nullptr) {
        std::cout << descriptionKindText(description->getKind()) << "\n";
        description = description->Parent;
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

template<typename Descriptor>
void printDescriptionName(const Descriptor* descriptor) {
    const char* name = descriptor->Name;
    std::cout << name << "\n";
}

void printMetadataName(const Metadata* metadata) {
//    std::cout << metadataKindText(metadata->getKind()) << "\n";
    switch (metadata->getKind()) {
        case MetadataKind::Class: {
            auto c = reinterpret_cast<const ClassMetadata*>(metadata);
//            std::cout << "MetadataKind::Class-> " << c << "\n" <<
//                "Description-> " << c->getDescription() << "\n";
            printDescriptionName(c->getDescription());
            break;
        }
        case MetadataKind::Struct: {
            auto c = reinterpret_cast<const StructMetadata*>(metadata);
//            std::cout << "MetadataKind::Struct-> " << c << "\n" <<
//                "Description-> " << c->getDescription() << "\n";
            printDescriptionName(c->getDescription());
            break;
        }
        case MetadataKind::Enum:
            break;
        case MetadataKind::Optional:
            break;
        case MetadataKind::ForeignClass:
            break;
        case MetadataKind::Opaque:
            break;
        case MetadataKind::Tuple:
            break;
        case MetadataKind::Function:
            break;
        case MetadataKind::Existential:
            break;
        case MetadataKind::Metatype:
            break;
        case MetadataKind::ObjCClassWrapper:
            break;
        case MetadataKind::ExistentialMetatype:
            break;
        case MetadataKind::HeapLocalVariable:
            break;
        case MetadataKind::HeapGenericLocalVariable:
            break;
        case MetadataKind::ErrorObject:
            break;
        case MetadataKind::LastEnumerated:
            break;
    }
}
