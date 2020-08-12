add_library(CReflection SHARED
    Runtime/Metadata.cpp
    Runtime/Errors.cpp
    Demangler.cpp
    Demangler.hpp
    Reflection.cpp
    Test.cpp
    Types.hpp
    include/Config.h
    include/CRDNodeKind.h
    include/CReflection.h
    include/Demangler.h
    include/Reflection.h
    include/Test.h
    include/Types.h)

set_target_properties(CReflection PROPERTIES
    LANGUAGE CXX
    LINKER_LANGUAGE CXX)

file(GLOB HEADERS
    *.h
    *.hpp
    ABI/Metadata.hpp
    include/*.h
    SwiftShims/*.h)

set_source_files_properties(${HEADERS} PROPERTIES
    HEADER_FILE_ONLY ON)

target_include_directories(CReflection PRIVATE
    External/swift/include
    External/release/swift/include
    External/llvm/include
    External/release/llvm/include)

target_link_options(CReflection PRIVATE -L/usr/lib/swift)

target_link_libraries(CReflection PRIVATE swiftDemangle objc)
