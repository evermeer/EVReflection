EVReflection/MoyaXML
============

This is the sub specification for a Moya Response extension for mapping XML with EVReflection 

# Installation

## CocoaPods

```ruby
pod 'EVReflection/MoyaXML'
```

# Advanced object mapping
This subspec can use all [EVReflection](https://github.com/evermeer/EVReflection) features like property mapping, converters, validators and key kleanup. See [EVReflection](https://github.com/evermeer/EVReflection) for more information.

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
