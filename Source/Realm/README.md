EVReflection/Realm
============

This is the sub specification for a [Realm](https://realm.io) extension for EVReflection

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
pod 'EVReflection/Realm'
```

# Advanced object mapping
This subspec can use all [EVReflection](https://github.com/evermeer/EVReflection) features like property mapping, converters, validators and key cleanup. See [EVReflection](https://github.com/evermeer/EVReflection) for more information.

# Usage

Extend your Realm objects with the EVReflectable protocol

```swift
import Foundation
import EVReflection
import RealmSwift

class Person: Object, EVReflectable {
   dynamic var name = ""
   dynamic var age = 0
   dynamic var spouse: Person?
   let cars = List<Car>()
}

class Car: Object, EVReflectable {
   dynamic var brand = ""  
   dynamic var name: String?
   dynamic var year = 0
}

```

You can then..:
```swift
// Init the realm file
let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "TemporaryRealm"))

func testRealmSmokeTest() {
   // Create the objects

   let wife = Person(json: "{\"name\": \"Jennifer\", \"age\": \"47\", \"cars\": [{\"brand\": \"DeLorean\", \"name\": \"Outatime\", \"year\": 1981} , {\"brand\": \"Volkswagen\", \"year\": 2014}], \"spouse\": {\"name\": \"Marty\", \"age\": \"48\"}}")

   // set the circular reference: The spouse of my spouse is me
   wife.spouse?.spouse = wife

   // You will see _EVReflection_parent_ with the value 1 to indicate that there is a circular reference to it's parent 1 level up.
   print("wife = \(wife.toJsonString())")
   // Now the object printed using Realm output functionality which just repeats itself until maximum depth is exeeded
   print("wife = \(wife)")


   // Write objects to the realm

   try! realm.write {
      realm.add(wife)
   }


   // Read objects back from the realm

   let favorites = ["Jennifer"]

   let favoritePeopleWithSpousesAndCars = realm.objects(Person.self)
      .filter("cars.@count > 1 && spouse != nil && name IN %@", favorites)
      .sorted(byKeyPath: "age")

   for person in favoritePeopleWithSpousesAndCars { 
      print(person.name)
      print(person.age)

      for car in person.cars {
         print("car.name = \(car.name ?? "")")
         print("car.brand = \(car.brand)")
         print("year = \(car.year)")
      }

      // Update objects
      guard let car = person.cars.first else {
         continue
      }

      print("old car.year = \(car.year)")
      try! realm.write {
         car.year += 3
      }
      print("new car.year = \(car.year)")
   }


   // Delete objects
   print("Number of persons in database before delete = \(realm.objects(Person.self).count)")

   try! realm.write {
      realm.deleteAll()
   }

   print("Number of persons in database after delete = \(realm.objects(Person.self).count)")
   // Thanks! To learn more about Realm go to https://realm.io    
}
```

