add_library(llvm
    Fake.cpp
    Hashing.cpp
    SmallVector.cpp)

target_include_directories(llvm PRIVATE
    ../../CReflection/External/llvm/include
    ../../CReflection/External/release/llvm/include)
