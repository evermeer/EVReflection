EVReflection/CoreData
============

This is the sub specification for a CoreData extension for EVReflection

# General information

If you have a question and don't want to create an issue, then we can [![Join the chat at https://gitter.im/evermeer/EVReflection](https://badges.gitter.im/evermeer/EVReflection.svg)](https://gitter.im/evermeer/EVReflection?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

EVReflection is used in [EVCloudKitDao](https://github.com/evermeer/EVCloudKitDao) and [EVWordPressAPI](https://github.com/evermeer/EVWordPressAPI)

In most cases EVReflection is very easy to use. Just take a look at the [YouTube tutorial](https://www.youtube.com/watch?v=LPWsQD2nxqg) or the section [It's easy to use](https://github.com/evermeer/EVReflection#its-easy-to-use). But if you do want to do non standard specific things, then EVReflection will offer you an extensive range of functionality.

### Available extensions
There are extension available for using EVReflection with [Realm](https://realm.io), [XMLDictionairy](https://github.com/nicklockwood/XMLDictionary), [CloudKit](https://developer.apple.com/library/content/documentation/DataManagement/Conceptual/CloudKitQuickStart/Introduction/Introduction.html), [Alamofire](https://github.com/Alamofire/Alamofire) and [Moya](https://github.com/Moya/Moya) with [RxSwift](https://github.com/ReactiveX/RxSwift) or [ReactiveSwift](https://github.com/ReactiveSwift/ReactiveSwift)

- [XML](https://github.com/evermeer/EVReflection/tree/master/Source/XML)
- [CloudKit](https://github.com/evermeer/EVReflection/tree/master/Source/CloudKit)
- [CoreData](https://github.com/evermeer/EVReflection/tree/master/Source/CoreData)
- [Realm](https://github.com/evermeer/EVReflection/tree/master/Source/Realm)
- [Alamofire](https://github.com/evermeer/EVReflection/tree/master/Source/Alamofire)
- [AlamofireXML](https://github.com/evermeer/EVReflection/tree/master/Source/XML)
- [Moya](https://github.com/evermeer/EVReflection/tree/master/Source/Alamofire/Moya)
- [MoyaXML](https://github.com/evermeer/EVReflection/tree/master/Source/Alamofire/Moya/XML)
- [MoyaRxSwift](https://github.com/evermeer/EVReflection/tree/master/Source/Alamofire/Moya/RxSwift)
- [MoyaRxSwiftXML](https://github.com/evermeer/EVReflection/tree/master/Source/Alamofire/Moya/RxSwift/XML)
- [MoyaReactiveSwift](https://github.com/evermeer/EVReflection/tree/master/Source/Alamofire/Moya/ReactiveSwift)
- [MoyaReactiveSwiftXML](https://github.com/evermeer/EVReflection/tree/master/Source/Alamofire/Moya/ReactiveSwift/XML)

# Installation

## CocoaPods

```ruby
pod 'EVReflection/CoreData'
```

# Advanced object mapping
This subspec can use all [EVReflection](https://github.com/evermeer/EVReflection) features like property mapping, converters, validators and key cleanup. See [EVReflection](https://github.com/evermeer/EVReflection) for more information.

# Usage

Create your core data model like you use to do.
Then from the menu Editor selec 'Create NSManegedObject subclass...' and generate all objects.
In your core data model set for all entities the Class CodeGen to Manual/None
then for all your NSManaged subclasses change NSManagedObject into EVManagedObject and import EVReflection

```swift
import Foundation
import CoreData
import EVReflection

@objc(CoreDataPerson)
public class CoreDataPerson: EVManagedObject {
}
```

Then creating an instance in your database based on a json string will work like this:
```swift
let moc: NSManagedObjectContext = EVReflectionTestsData().moc // Your code for getting the NSManagedObjectContext.

let obj = CoreDataPerson(context: moc, json: "{\"firstName\" : \"Edwin\", \"lastName\" : \"Vermeer\"}")

try! moc.save() //You should implement error handling
```

Parsing an object array is just as easy:
```swift
let moc: NSManagedObjectContext = EVReflectionTestsData().moc // Your code for getting the NSManagedObjectContext.

let arr = [CoreDataPerson](context: moc, json: "[{\"firstName\" : \"Edwin\", \"lastName\" : \"Vermeer\"},{\"firstName\" : \"Edwin 2\", \"lastName\" : \"Vermeer 2\"}]")

try! moc.save() //You should implement error handling
```




