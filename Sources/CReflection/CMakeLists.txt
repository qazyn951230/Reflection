add_subdirectory(llvm)
add_subdirectory(runtime)

add_library(Runtime SHARED
    include/Config.h
    include/CReflection.h
    CReflection.cpp)

set_target_properties(Runtime PROPERTIES
    LANGUAGE CXX
    LINKER_LANGUAGE CXX)

file(GLOB HEADERS
    *.h
    *.hpp)

set_source_files_properties(${HEADERS} PROPERTIES
    HEADER_FILE_ONLY ON)

target_include_directories(Runtime PRIVATE
    External/swift/include
    External/release/swift/include
    External/llvm/include
    External/release/llvm/include)

target_link_options(Runtime PRIVATE -L/usr/lib/swift)

target_link_libraries(Runtime PRIVATE
    swiftCore swiftDemangle objc
    swift_runtime llvm)
