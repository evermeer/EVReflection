EVReflection/MoyaReactiveCocoa
============

This is the sub specification for a Moya plus ReactiveCocoa SignalProducer extension for EVReflection

# Installation

## CocoaPods

```ruby
pod 'EVReflection/MoyaReactiveCocoa'
```

# Usage

For more information about using Moya plus ReactiveCocoa have a look at the [Moya](https://github.com/Moya/Moya) project.
For more information about the usage of EVReflection have a look at the cor [EVReflection](https://github.com/evermeer/EVReflection) functionality

Create a class which has `EVObject` as it's base class. You could also use any `NSObject` based class and extend it with the `EVReflectable` protocol. 

```swift
import Foundation
import EVReflection

class Repository: EVObject {
    var identifier: NSNumber?
    var language: String?
    var url: String?
}
```

Then on the Moya provider execute a `.map(toArray:` or a `.map(to:)` and then `.subscribe` to it.

```swift
GitHubProvider.request(.userRepositories(username))
.map(toArray: Repository)
.??? TODO
```
