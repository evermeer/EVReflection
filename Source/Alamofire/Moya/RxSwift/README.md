EVReflection/MoyaRxSwift
============

This is the sub specification for a Moya plus RxSwift Observable extension for EVReflection

# Installation

## CocoaPods

```ruby
pod 'EVReflection/MoyaRxSwift'
```

# Advanced object mapping
This subspec can use all [EVReflection](https://github.com/evermeer/EVReflection) features like property mapping, converters, validators and key kleanup. See [EVReflection](https://github.com/evermeer/EVReflection) for more information.

# Usage

For more information about using Moya plus RxSwift have a look at the [Moya](https://github.com/Moya/Moya) project.
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
.subscribe { event -> Void in
    switch event {
        case .Next(let repos):
            self.repos = repos
        case .Error(let error):
            print(error)
        default:
            break
    }
}.addDisposableTo(disposeBag)
```
