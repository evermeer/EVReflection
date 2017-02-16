# EVReflection

<!---
[![Circle CI](https://img.shields.io/circleci/project/evermeer/EVReflection.svg?style=flat)](https://circleci.com/gh/evermeer/EVReflection)
[![Build Status](https://travis-ci.org/evermeer/EVReflection.svg?style=flat)](https://travis-ci.org/evermeer/EVReflection)
 -->
[![Issues](https://img.shields.io/github/issues-raw/evermeer/EVReflection.svg?style=flat)](https://github.com/evermeer/EVReflection/issues)
[![Coverage](https://img.shields.io/badge/coverage-78%25-yellow.svg?style=flat)](https://raw.githubusercontent.com/evermeer/EVReflection/master/UnitTests/coverage.png)
[![Documentation](https://img.shields.io/badge/documented-97%25-green.svg?style=flat)](http://cocoadocs.org/docsets/EVReflection/3.7.0/)
[![Stars](https://img.shields.io/github/stars/evermeer/EVReflection.svg?style=flat)](https://github.com/evermeer/EVReflection/stargazers)
[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/matteocrippa/awesome-swift#json)
[![Downloads](https://img.shields.io/cocoapods/dt/EVReflection.svg?style=flat)](https://cocoapods.org/pods/EVReflection)


[![Version](https://img.shields.io/cocoapods/v/EVReflection.svg?style=flat)](http://cocoadocs.org/docsets/EVReflection)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Language](https://img.shields.io/badge/language-swift 3-f48041.svg?style=flat)](https://developer.apple.com/swift)
[![Platform](https://img.shields.io/cocoapods/p/EVReflection.svg?style=flat)](http://cocoadocs.org/docsets/EVReflection)
[![License](https://img.shields.io/cocoapods/l/EVReflection.svg?style=flat)](http://cocoadocs.org/docsets/EVReflection)

[![Git](https://img.shields.io/badge/GitHub-evermeer-blue.svg?style=flat)](https://github.com/evermeer)
[![Twitter](https://img.shields.io/badge/twitter-@evermeer-blue.svg?style=flat)](http://twitter.com/evermeer)
[![LinkedIn](https://img.shields.io/badge/linkedin-Edwin Vermeer-blue.svg?style=flat)](http://nl.linkedin.com/in/evermeer/en)
[![Website](https://img.shields.io/badge/website-evict.nl-blue.svg?style=flat)](http://evict.nl)
[![eMail](https://img.shields.io/badge/email-edwin@evict.nl-blue.svg?style=flat)](mailto:edwin@evict.nl?SUBJECT=About EVReflection)

# General information

If you have a question and don't want to create an issue, then we can [![Join the chat at https://gitter.im/evermeer/EVReflection](https://badges.gitter.im/evermeer/EVReflection.svg)](https://gitter.im/evermeer/EVReflection?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

At this moment the master branch is for Swift 3. If you want to continue using EVReflection in Swift 2.2 (or 2.3) then switch to the Swift2.2 or Swift2.3 branch.
Run the unit tests to see EVReflection in action.

EVReflection is used in [EVCloudKitDao](https://github.com/evermeer/EVCloudKitDao) and [EVWordPressAPI](https://github.com/evermeer/EVWordPressAPI)

In most cases EVReflection is very easy to use. Just take a look the section [It's easy to use](https://github.com/evermeer/EVReflection#its-easy-to-use). But if you do want to do non standard specific things, then EVReflection will offer you an extensive range of functionality. 

### Available extensions
There are extension available for using EVReflection with [XMLDictionairy](https://github.com/nicklockwood/XMLDictionary), [CloudKit](https://developer.apple.com/library/content/documentation/DataManagement/Conceptual/CloudKitQuickStart/Introduction/Introduction.html), [Alamofire](https://github.com/Alamofire/Alamofire) and [Moya](https://github.com/Moya/Moya) with [RxSwift](https://github.com/ReactiveX/RxSwift) or [ReactiveSwift](https://github.com/ReactiveSwift/ReactiveSwift)

- [XML](https://github.com/evermeer/EVReflection/tree/master/Source/XML)
- [CloudKit](https://github.com/evermeer/EVReflection/tree/master/Source/CloudKit)
- [Alamofire](https://github.com/evermeer/EVReflection/tree/master/Source/Alamofire)
- [AlamofireXML](https://github.com/evermeer/EVReflection/tree/master/Source/XML)
- [Moya](https://github.com/evermeer/EVReflection/tree/master/Source/Alamofire/Moya)
- [MoyaXML](https://github.com/evermeer/EVReflection/tree/master/Source/Alamofire/Moya/XML)
- [MoyaRxSwift](https://github.com/evermeer/EVReflection/tree/master/Source/Alamofire/Moya/RxSwift)
- [MoyaRxSwiftXML](https://github.com/evermeer/EVReflection/tree/master/Source/Alamofire/Moya/RxSwift/XML)
- [MoyaReactiveSwift](https://github.com/evermeer/EVReflection/tree/master/Source/Alamofire/Moya/ReactiveSwift)
- [MoyaReactiveSwiftXML](https://github.com/evermeer/EVReflection/tree/master/Source/Alamofire/Moya/ReactiveSwift/XML)

All these extens can be installed by adding something like this in your podfile:

```
pod 'EVReflection/MoyaRxSwift'
```

## Index

- [Main features of EVReflection](https://github.com/evermeer/EVReflection#main-features-of-evreflection)
- [Quick start](https://github.com/evermeer/EVReflection#quick-start)
- [It's easy to use](https://github.com/evermeer/EVReflection#its-easy-to-use)
- [If you have XML instead of JSON](https://github.com/evermeer/EVReflection#if-you-have-xml-instead-of-json)
- [Using EVReflection in your own App](https://github.com/evermeer/EVReflection#using-evreflection-in-your-own-app)
- [More Sample code](https://github.com/evermeer/EVReflection#more-sample-code)
- [Extending existing objects](https://github.com/evermeer/EVReflection#extending-existing-objects)
- [Conversion options](https://github.com/evermeer/EVReflection#conversion-options)
- [Automatic keyword mapping for Swift keywords](https://github.com/evermeer/EVReflection#automatic-keyword-mapping-for-swift-keywords)
- [Automatic keyword mapping PascalCase or camelCase to snake_case](https://github.com/evermeer/EVReflection#automatic-keyword-mapping-pascalcase-or-camelcase-to-snake_case)
- [Custom keyword mapping](https://github.com/evermeer/EVReflection#custom-keyword-mapping)
- [Custom property converters](https://github.com/evermeer/EVReflection#custom-property-converters)
- [Skip the serialization or deserialization of specific values](https://github.com/evermeer/EVReflection#skip-the-serialization-or-deserialization-of-specific-values)
- [Property validators](https://github.com/evermeer/EVReflection#property-validators)
- [Deserialization class level validations](https://github.com/evermeer/EVReflection#deserialization-class-level-validations)
- [What to do when you use object inheritance](https://github.com/evermeer/EVReflection#what-to-do-when-you-use-object-inheritance)
- [Known issues](https://github.com/evermeer/EVReflection#known-issues)
- [License](https://github.com/evermeer/EVReflection#license)
- [My other libraries](https://github.com/evermeer/EVReflection#my-other-libraries)

## Main features of EVReflection:
- Parsing objects based on NSObject to and from a dictionary. (also see the XML and .plist samples!)
- Parsing objects to and from a JSON string.
- Support NSCoding function encodeWithCoder and decodeObjectWithCoder
- Supporting Printable, Hashable and Equatable while using all properties.
- Mapping objects from one type to an other
- Support for property mapping, converters, validators and key cleanup

## Quick start
For a quick start have a look at this [YouTube tutorial](https://www.youtube.com/watch?v=LPWsQD2nxqg).

## It's easy to use:

Defining an object. You only have to set EVObject as it's base class (or extend an NSObject with EVReflectable):
```swift
class User: EVObject {
    var id: Int = 0
    var name: String = ""
    var friends: [User]? = []
}
```

Parsing JSON to an object:
```swift
let json:String = "{\"id\": 24, \"name\": \"Bob Jefferson\", \"friends\": [{\"id\": 29, \"name\": \"Jen Jackson\"}]}"
let user = User(json: json)
```

Parsing JSON to an array of objects:
```swift
let json:String = "[{\"id\": 27, \"name\": \"Bob Jefferson\"}, {\"id\": 29, \"name\": \"Jen Jackson\"}]"
let array = [User](json: json)
```

Parsing from and to a dictionary:
```swift
let dict = user.toDictionary()
let newUser = User(dictionary: dict)
XCTAssert(user == newUser, "Pass")
```

Saving and loading an object to and from a file:
```swift
user.saveToTemp("temp.dat")
let result = User(fileNameInTemp: "temp.dat")
XCTAssert(theObject == result, "Pass")
```

Mapping object to another type:
```swift
let administrator: Administrator = user.mapObjectTo()
```


## If you have XML instead of JSON

If you want to do the same but you have XML, then you can achieve that using the XML subspec 'pod EVReflection/XML' It is a simple way to parse XML. With that your code will look like this:

```swift
let xml = "<user><id>27</id><name>Bob</name><friends><user><id>20</id><name>Jen</name></user></friends></user>"
let user = User(xml: xml)
```

## Using EVReflection in your own App 

'EVReflection' is available through the dependency manager [CocoaPods](http://cocoapods.org). 
You do have to use cocoapods version 0.36 or later

You can just add EVReflection to your workspace by adding the following 2 lines to your Podfile:

```
use_frameworks!
pod "EVReflection"
```

You can also use the Swift2.2 or Swift2.3 version of EVReflection. You can get that version by using the podfile command:
```
use_frameworks!
pod "EVReflection"', :git => 'https://github.com/evermeer/EVReflection.git', :branch => 'Swift2.2'
```

Version 0.36 of cocoapods will make a dynamic framework of all the pods that you use. Because of that it's only supported in iOS 8.0 or later. When using a framework, you also have to add an import at the top of your swift file like this:

```swift
import EVReflection
```

If you want support for older versions than iOS 8.0, then you can also just copy the files from the pod folder to your project. You do have to use the Swift2.3 version or older. iOS 7 support is dropped from Swift 3.

Be aware that when you have your object definitions in a framework and not in your main app, then you have to let EVReflection know that it should also look in that framework for your classes. This can easilly be done by using the following one liner (for instance in the appdelegate)
```swift
EVReflection.setBundleIdentifier(YourDataObject.self)
```
 

## More Sample code 
Clone EVReflection to your desktop to see these and more unit tests

```swift
func testEquatable() {
    var theObjectA = TestObject2()
    theObjectA.objectValue = "value1"
    var theObjectB = TestObject2()
    theObjectB.objectValue = "value1"
    XCTAssert(theObjectA == theObjectB, "Pass")

    theObjectB.objectValue = "value2"
    XCTAssert(theObjectA != theObjectB, "Pass")
}

func testHashable() {
    var theObject = TestObject2()
    theObject.objectValue = "value1"
    var hash1 = theObject.hash
    NSLog("hash = \(hash)")
}

func testPrintable() {
    var theObject = TestObject2()
    theObject.objectValue = "value1"
    NSLog("theObject = \(theObject)")
}

func testArrayFunctions() {
    let dictionaryArray: [NSDictionary] = yourGetDictionaryArrayFunction()
    let userArray = [User](dictionaryArray: dictionaryArray)
    let newDictionaryArray = userArray.toDictionaryArray()
}

func testMapping() {
    let player = GamePlayer()
    player.name = "It's Me"

    let administrator = GameAdministrator(usingValuesFrom: player)
}
```

Direct conversion from a NSDictionary (or an array of NSDictionaries) to json and back.
```swift
let dict1: NSDictionary = [
  "requestId": "request",
  "postcode": "1111AA",
  "houseNumber": "1"
]
let json = dict1.toJsonString()
let dict2 = NSMutableDictionary(json: json)
print("dict:\n\(dict1)\n\njson:\n\(json)\n\ndict2:\n\(dict2)")

// You can do the same with arrays
let array:[NSDictionary] = [dict1, dict2]
let jsonArray = array.toJsonStringArray()
let array2 = [NSDictionary](jsonArray: jsonArray)
print("json array: \n\(jsonArray)\n\narray2:\n\(array2)")
```


This is how you can parse a .plist into an object model. See EVReflectionIssue124.swift to see it working.
```swift
   if let path = Bundle(for: type(of: self)).path(forResource: "EVReflectionIssue124", ofType: "plist") {
       if let data = NSDictionary(contentsOfFile: path) {
          let plistObject = Wrapper(dictionary: data)
          print(plistObject)
       }
   }
```

If you want to parse XML, then you can use the pod subxpec EVReflection/XML
```swift
    let xml: String = "<data><item name=\"attrib\">itemData</item></data>"
    let xmlObject = MyObject(xml: xml)
    print(xmlObject)
```

## Extending existing objects:
It is possible to extend other objects with the EVReflectable protocol instead of changing the base class to EVObject. This will let you add the power of EVReflection to objects that also need another framework. If for instance you are using Realm, you can extend all your Object classes with the power of EVReflection by only adding these lines of code:

```swift
import EVReflection
extension Object : EVReflectable { }
```
You can do the same with NSManagedObject

## Extra information:

### Conversion options
With almost any EVReflection function you can specify what kind of conversion options should be used. This is done using an option set. You can use the following conversion options:

- None - Do not use any conversion function.
- [PropertyConverter](https://github.com/evermeer/EVReflection#custom-property-converters) : If specified the function propertyConverters on the EVObject will be called
- [PropertyMapping](https://github.com/evermeer/EVReflection#custom-keyword-mapping) : If specified the function propertyMapping on the EVObject will be called
- [SkipPropertyValue](https://github.com/evermeer/EVReflection#skip-the-serialization-or-deserialization-of-specific-values) : If specified the function skipPropertyValue on the EVObject will be called
- [KeyCleanup](https://github.com/evermeer/EVReflection#automatic-keyword-mapping-pascalcase-or-camelcase-to-snake_case) : If specified the automatic pascalCase and snake_case property key mapping will be called.

In EVReflection all functions will use a default conversion option specific to it's function. The following 4 default conversion types are used: 
- DefaultNSCoding = [None]
- DefaultComparing = [PropertyConverter, PropertyMapping, SkipPropertyValue]
- DefaultDeserialize = [PropertyConverter, PropertyMapping, SkipPropertyValue, KeyCleanup]
- DefaultSerialize = [PropertyConverter, PropertyMapping, SkipPropertyValue]

If you want to change one of the default conversion types, then you can do that using something like:
```swift
ConversionOptions.DefaultNSCoding = [.PropertyMapping]
```


### Automatic keyword mapping for Swift keywords
If you have JSON fields that are Swift keywords, then prefix the property with an underscore. So the JSON value for self will be stored in the property `\_self`. At this moment the following keywords are handled:

"self", "description", "class", "deinit", "enum", "extension", "func", "import", "init", "let", "protocol", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "do", "else", "fallthrough", "if", "in", "for", "return", "switch", "where", "while", "as", "dynamicType", "is", "new", "super", "Self", "Type", "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__", "associativity", "didSet", "get", "infix", "inout", "left", "mutating", "none", "nonmutating", "operator", "override", "postfix", "precedence", "prefix", "right", "set", "unowned", "unowned", "safe", "unowned", "unsafe", "weak", "willSet", "private", "public"

### Automatic keyword mapping PascalCase or camelCase to snake_case
When creating objects from JSON EVReflection will automatically detect if snake_case (keys are all lowercase and words are separated by an underscore) should be converted to PascalCase or camelCase property names. See [Conversion options](https://github.com/evermeer/EVReflection#conversion-options) for when this function will be called.

When exporting object to a dictionary or JSON string you will have an option to specify that you want a conversion to snace_case or not. The default is .DefaultDeserialize which will also convert to snake case.

```swift
let jsonString = myObject.toJsonString([.DefaultSerialize])
let dict = myObject.toDictionary([PropertyConverter, PropertyMapping, SkipPropertyValue])
```


### Custom keyword mapping
It's also possible to create a custom property mapping. You can define if an import should be ignored, if an export should be ignored or you can map a property name to another key name (for the dictionary and json). For this you only need to implement the propertyMapping function in the object. See [Conversion options](https://github.com/evermeer/EVReflection#conversion-options) for when this function will be called.

```swift
public class TestObject5: EVObject {
    var Name: String = "" // Using the default mapping
    var propertyInObject: String = "" // will be written to or read from keyInJson
    var ignoredProperty: String = "" // Will not be written or read to/from json 

    override public func propertyMapping() -> [(String?, String?)] {
        return [("ignoredProperty",nil), ("propertyInObject","keyInJson")]
    }
}
```

### Custom property converters
You can also use your own property converters. For this you need to implement the propertyConverters function in your object. For each property you can create a custom getter and setter that will then be used by EVReflection. In the sample below the JSON texts 'Sure' and 'Nah' will be converted to true or false for the property isGreat. See [Conversion options](https://github.com/evermeer/EVReflection#conversion-options) for when this function will be called.
```swift
public class TestObject6: EVObject {
    var isGreat: Bool = false

    override func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [
            ( // We want a custom converter for the field isGreat
              key: "isGreat"
              // isGreat will be true if the json says 'Sure'
              , decodeConverter: { self.isGreat = ($0 as? String == "Sure") }
              // The json will say 'Sure  if isGreat is true, otherwise it will say 'Nah'
              , encodeConverter: { return self.isGreat ? "Sure": "Nah"})
        ]
    }
}
```

### Skip the serialization or deserialization of specific values
When there is a need to not (de)serialize specific values like nil NSNull or empty strings you can implement the skipPropertyValue function and return true if the value needs to be skipped. See [Conversion options](https://github.com/evermeer/EVReflection#conversion-options) for when this function will be called.

```swift
class TestObjectSkipValues: EVObject {
   var value1: String? 
   var value2: [String]?
   var value3: NSNumber?

   override func skipPropertyValue(value: Any, key: String) -> Bool {
      if let value = value as? String where value.characters.count == 0 || value == "null" {
         print("Ignoring empty string for key \(key)")
         return true
      } else if let value = value as? NSArray where value.count == 0 {
         print("Ignoring empty NSArray for key\(key)")
         return true
      } else if value is NSNull {
         print("Ignoring NSNull for key \(key)")
         return true
      }
      return false
   }
}
```

### Property validators
Before setting a value the value will always be validated using the standard validateValue KVO function. This means that for every property you can also create a validation function for that property. See the sample below where there is a validateName function for the name property.

```swift
enum MyValidationError: ErrorType {
   case TypeError,
   LengthError
}

public class GameUser: EVObject {
   var name: String?
   var memberSince: NSDate?
   var objectIsNotAValue: TestObject?

   func validateName(value:AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {
      if let theValue = value.memory as? String {
         if theValue.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 3 {
            NSLog("Validating name is not long enough \(theValue)")
            throw MyValidationError.LengthError
         }
         NSLog("Validating name OK \(theValue)")
      } else {
         NSLog("Validating name is not a string: \(value.memory)")
         throw MyValidationError.TypeError
     }
   }
}
```

### Deserialization class level validations
There is also support for class level validation when deserializing to an object. There are helper functions for making keys required or not allowed. You can also add custom messages. Here is some sample code about how you can implement such a validation

```swift
public class ValidateObject: EVObject {
   var requiredKey1: String?
   var requiredKey2: String?
   var optionalKey1: String?

   override public func initValidation(dict: NSDictionary) {
      self.initMayNotContainKeys(["error"], dict: dict)
      self.initMustContainKeys(["requiredKey1", "requiredKey2"], dict: dict)
      if dict.valueForKey("requiredKey1") as? String == dict.valueForKey("optionalKey1") as? String {
         // this could also be called in your property specific validators
         self.addStatusMessage(.Custom, message: "optionalKey1 should not be the same as requiredKey1")
      }
   }
}
```
You could then test this validation with code like:
```swift
func testValidation() {
   // Test missing required key
   let json = "{\"requiredKey1\": \"Value1\"}"
   let test = ValidateObject(json: json)
   XCTAssertNotEqual(test.evReflectionStatus(), .None, "We should have a not .None status")
   XCTAssertEqual(test.evReflectionStatuses.count, 1, "We should have 1 validation result")
   for (status, message) in test.evReflectionStatuses {
      print("Validation result: Status = \(status), Message = \(message)")
   }
}
```

### What to do when you use object inheritance
You can deserialize json to an object that uses inheritance. When the properties are specified as the base class, then the correct specific object type will be returned by the function `getSpecificType`. See the sample code below or the unit test in EVReflectionInheritanceTests.swift

```swift
class Quz: EVObject {
    var fooArray: Array<Foo> = []
    var fooBar: Foo?
    var fooBaz: Foo?
}

class Foo: EVObject {
    var allFoo: String = "all Foo"

    // What you need to do to get the correct type for when you deserialize inherited classes
    override func getSpecificType(dict: NSDictionary) -> EVObject {
        if dict["justBar"] != nil {
            return Bar()
        } else if dict["justBaz"] != nil {
            return Baz()
        }
        return self
    }
}

class Bar : Foo {
    var justBar: String = "For bar only"
}

class Baz: Foo {
    var justBaz: String = "For baz only"
}
```


### Known issues
EVReflection is trying to handle all types. With some types there are limitations in Swift. So far there is a workaround for any of these limitations. Here is an overview:

####It's not possible in Swift to use .setObjectForKey for:
- nullable type fields like Int? 
- properties based on an enum
- an Array of nullable objects like [MyObject?] 
- a Set like Set<MyObject>
- generic properties like var myVal:T = T()
- structs like CGRect or CGPoint

For all these issues there are workarounds. The easiest workaround is just using a difrent type like:

- Instead of an Int? you could use NSNumber?
- Instead of [MyObject?] use [MyObject]
- Instead of Set<MyObject> use [MyObject]
- Instead of 'var status: StatysType' use 'var status:Int' and save the rawValue
- Instead of a generic property use a specific property that can hold the data (a dictionary?)
- Instead of using a struct, create your own object model for that struct

If you want to keep on using the same type, You can override the setValue forUndefinedKey in the object itself. See WorkaroundsTests.swift and WorkaroundSwiftGenericsTests.swift to see the workaround for all these types in action. 

####Generic properties
For generic properties the protocol EVGenericsKVC is required. see WorkaroundSwiftGenericsTests.swift 

####Arrays with nullable objects or Set's
For arrays with nullable objects or Set's like [MyObj?] or Set<MyObj> the protocol EVArrayConvertable is required. see WorkaroundsTests.swift

####Swift Dictionaries
For Swift Dictionaries (and not NSDictionary) the protocol EVDictionaryConvertable is required. See WorkaroundsTests.swift

## License

EVReflection is available under the MIT 3 license. See the LICENSE file for more info.

## My other libraries:
Also see my other public source iOS libraries:

- [EVReflection](https://github.com/evermeer/EVReflection) - Reflection based (Dictionary, CKRecord, JSON and XML) object mapping with extensions for Alamofire and Moya with RxSwift or ReactiveSwift 
- [EVCloudKitDao](https://github.com/evermeer/EVCloudKitDao) - Simplified access to Apple's CloudKit
- [EVFaceTracker](https://github.com/evermeer/EVFaceTracker) - Calculate the distance and angle of your device with regards to your face in order to simulate a 3D effect
- [EVURLCache](https://github.com/evermeer/EVURLCache) - a NSURLCache subclass for handling all web requests that use NSURLReques
- [AlamofireOauth2](https://github.com/evermeer/AlamofireOauth2) - A swift implementation of OAuth2 using Alamofire
- [EVWordPressAPI](https://github.com/evermeer/EVWordPressAPI) - Swift Implementation of the WordPress (Jetpack) API using AlamofireOauth2, AlomofireJsonToObjects and EVReflection (work in progress)
- [PassportScanner](https://github.com/evermeer/PassportScanner) - Scan the MRZ code of a passport and extract the firstname, lastname, passport number, nationality, date of birth, expiration date and personal numer.
- [AttributedTextView](https://github.com/evermeer/AttributedTextView) - Easiest way to create an attributed UITextView with support for multiple links (url, hashtags, mentions).

## Evolution of EVReflection (Gource Visualization)
[![Evolution of EVReflection (Gource Visualization)](https://img.youtube.com/vi/FIETlttIFh8/0.jpg)](https://www.youtube.com/watch?v=FIETlttIFh8)
