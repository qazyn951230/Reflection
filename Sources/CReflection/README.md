1. Checkout Swift source codes
```shell script
cd /PATH/TO/SWIFT_SOURCES/swift
./utils/update-checkout --tag swift-5.2.4-RELEASE
```

2. Preparear header fiels
```shell script
cd /PATH/TO/SWIFT_SOURCES
swift/utils/build-script --release-debuginfo -S
mkdir build/release
ln -s ../Ninja-RelWithDebInfoAssert/llvm-macosx-x86_64 build/release/llvm
ln -s ../Ninja-RelWithDebInfoAssert/swift-macosx-x86_64 build/release/swift
```

3. Preparear header link destination
```shell script
mkdir llvm swift release release/llvm release/swift
```

4. Link header files
```shell script
ln -s /PATH/TO/SWIFT_SOURCES/llvm-project/llvm/include llvm/include
ln -s /PATH/TO/SWIFT_SOURCES/swift/include swift/include
ln -s /PATH/TO/SWIFT_SOURCES/build/release/llvm/include release/llvm/include
ln -s /PATH/TO/SWIFT_SOURCES/build/release/swift/include release/swift/include
```
