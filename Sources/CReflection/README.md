```shell script
cd /PATH/TO/SWIFT_SOURCES/swift
./utils/update-checkout --tag swift-5.2.4-RELEASE
```

```shell script
cd /PATH/TO/SWIFT_SOURCES
swift/utils/build-script --release-debuginfo -S
ln -s build/Ninja-RelWithDebInfoAssert build/release
```

```shell script
ln -s /PATH/TO/SWIFT_SOURCES/llvm-project/llvm/include llvm/include
ln -s /PATH/TO/SWIFT_SOURCES/swift/include swift/include
ln -s /PATH/TO/SWIFT_SOURCES/build/release/llvm/include release/llvm/include
ln -s /PATH/TO/SWIFT_SOURCES/build/release/swift/include release/swift/include
```
