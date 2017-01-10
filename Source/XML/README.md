EVReflection/XML
============

This is the sub specification for a Xml2Dictionary extension for EVReflection

# Installation

## CocoaPods

```ruby
pod 'EVReflection/XML'
```

# Advanced object mapping
This subspec can use all [EVReflection](https://github.com/evermeer/EVReflection) features like property mapping, converters, validators and key kleanup. See [EVReflection](https://github.com/evermeer/EVReflection) for more information.

# Usage

Create a class which has `EVObject` as it's base class. You could also use any `NSObject` based class and extend it with the `EVReflectable` protocol. 

```swift
import Foundation
import EVReflection

class User: EVObject {
    var name: String?
    var email: String?
}
```

You can then create such an object using:
```swift
let user = User(xml: "<root><name>Edwin</name><email>edwin@evict.nl</email></root>")
```
