# Concurrency
An easy-to-use and lightweight concurrency utilities for thread safty in swift

## Communication

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Concurrency into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
use_frameworks!

target '<Your Target Name>' do
    pod 'Concurrency', '~> 0.0.1'
end
```

Then, run the following command:

```bash
$ pod install
```

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

> Xcode 13+ is required to build Concurrency using Swift Package Manager.

To integrate Concurrency into your Xcode project using Swift Package Manager, add it to the dependencies value of your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/tjerwinchen/Concurrency.git", .upToNextMajor(from: "0.0.1"))
]
```

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate Concurrency into your project manually.

---

## Usage

### Quick Start

#### Concurrent Dictionary
```swift
import Concurrency

struct AwesomeStruct {
  @ConcurrentDictionary
  var dictionary = [String: String]()

  func foo() {
    $dictionary["key"] = "value"
    $dictionary.removeAll()
  }
}
```

#### Concurrent Array
```swift
import Concurrency

struct AwesomeStruct {
  @ConcurrentArray
  var array: [String] = []

  func foo() {
    $array.append(1)
    $array.append(2)
    $array = 3
    $array.removeAll()
  }
}

```

#### Any Concurrent Type
```swift
import Concurrency

class AwesomeClass {
  var intValue = 0
  var boolValue = false
}

@Concurrency
var awesomeClass = AwesomeClass()

$awesomeClass.updateValue { value in
  if value.boolValue {
    value.intValue += 1
  } else {
    value.intValue -= 1
  }
  value.boolValue = !value.boolValue
  return value
}

print($awesomeClass.safeValue)

var flag = true
$awesomeClass.readValue { value in
  ...
  
  flag = value.boolValue
}
```

## License

Concurrency is released under the MIT license. See LICENSE for details.
