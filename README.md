# Reflection (WIP)

A swift reflection framework, aim to provide a set API of reflection which is similar to Java.

Currently focus on `Swift.dump` implementation.
Note the following code is the very early version.

```swift
import Reflection

struct Foobar {
    let value = 12
    let bar = false
}

dump(Foobar())
// Prints
// ▿ struct Demo.Foobar
// Swift.Int name: value, 0
// Swift.Bool name: bar, 8
```
