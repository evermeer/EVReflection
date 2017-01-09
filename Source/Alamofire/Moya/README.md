EVReflection/Moya
============

This is the sub specification for a Moya Response extension for EVReflection

# Installation

## CocoaPods

```ruby
pod 'EVReflection/Moya'
```

# Usage

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

```swift
GitHubProvider.request(.userRepositories(username), completion: { result in

    var success = true
    var message = "Unable to fetch from GitHub"

    switch result {
    case let .success(response):
        do {
            if let repos = try response.mapArray(Repository) {
              self.repos = repos
            } else {
              success = false
            }
        } catch {
            success = false
        }
        self.tableView.reloadData()
    case let .failure(error):
        guard let error = error as? CustomStringConvertible else {
            break
        }
        message = error.description
        success = false
    }
})

```

## 2. With RxSwift

```swift
GitHubProvider.request(.userRepositories(username))
  .mapArray(Repository)
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
