add_library(swift_runtime
    BackDeployment.cpp
    Casting.cpp
    CompatibilityOverride.cpp
    CompatibilityOverride.h
    Demangle.cpp
    EnumImpl.h
    ErrorObject.h
    Errors.cpp
    ExistentialMetadataImpl.h
    ImageInspection.h
    ImageInspectionELF.h
    ImageInspectionMachO.cpp
    Metadata.cpp
    MetadataCache.h
    MetadataImpl.h
    MetadataLookup.cpp
    MutexPThread.cpp
    ObjCRuntimeGetImageNameFromClass.h
    Private.h
    ProtocolConformance.cpp
    SwiftHashableSupport.h
    SwiftObject.h
    SwiftObject.mm
    SwiftValue.h
    WeakReference.h)

set_target_properties(swift_runtime PROPERTIES
    LANGUAGE CXX
    LINKER_LANGUAGE CXX)

file(GLOB HEADERS
    *.h
    *.hpp)

set_source_files_properties(${HEADERS} PROPERTIES
    HEADER_FILE_ONLY ON)

target_compile_options(swift_runtime PRIVATE
    -Wno-deprecated-declarations
    -Wno-pointer-bool-conversion
    -Wno-tautological-pointer-compare)

target_include_directories(swift_runtime PRIVATE
    ../External/swift/include
    ../External/release/swift/include
    ../External/llvm/include
    ../External/release/llvm/include)

target_link_options(swift_runtime PRIVATE -L/usr/lib/swift)

target_link_libraries(swift_runtime PRIVATE
    swiftCore swiftDemangle objc
    llvm)
