# EVReflection

<!---
[![Circle CI](https://img.shields.io/circleci/project/evermeer/EVReflection.svg?style=flat)](https://circleci.com/gh/evermeer/EVReflection)
 -->
[![Build Status](https://travis-ci.org/evermeer/EVReflection.svg?style=flat)](https://travis-ci.org/evermeer/EVReflection)
[![Issues](https://img.shields.io/github/issues-raw/evermeer/EVReflection.svg?style=flat)](https://github.com/evermeer/EVReflection/issues)
[![Coverage](https://img.shields.io/badge/coverage-99%-brightgreen.svg?style=flat)](https://raw.githubusercontent.com/evermeer/EVReflection/master/EVReflection/coverage.png)
[![Documentation](https://img.shields.io/badge/documented-100%-brightgreen.svg?style=flat)](http://cocoadocs.org/docsets/EVReflection)
[![Stars](https://img.shields.io/github/stars/evermeer/EVReflection.svg?style=flat)](https://github.com/evermeer/EVReflection/stargazers)

[![Version](https://img.shields.io/cocoapods/v/EVReflection.svg?style=flat)](http://cocoadocs.org/docsets/EVReflection)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Language](https://img.shields.io/badge/language-swift2-f48041.svg?style=flat)](https://developer.apple.com/swift)
[![Platform](https://img.shields.io/cocoapods/p/EVReflection.svg?style=flat)](http://cocoadocs.org/docsets/EVReflection)
[![License](https://img.shields.io/cocoapods/l/EVReflection.svg?style=flat)](http://cocoadocs.org/docsets/EVReflection)

[![Git](https://img.shields.io/badge/GitHub-evermeer-blue.svg?style=flat)](https://github.com/evermeer)
[![Twitter](https://img.shields.io/badge/twitter-@evermeer-blue.svg?style=flat)](http://twitter.com/evermeer)
[![LinkedIn](https://img.shields.io/badge/linkedin-Edwin Vermeer-blue.svg?style=flat)](http://nl.linkedin.com/in/evermeer/en)
[![Website](https://img.shields.io/badge/website-evict.nl-blue.svg?style=flat)](http://evict.nl)
[![eMail](https://img.shields.io/badge/email-edwin@evict.nl-blue.svg?style=flat)](mailto:edwin@evict.nl?SUBJECT=About EVReflection)


Run the unit tests to see EVReflection in action.

EVReflection is used extensively in [EVCloudKitDao](https://github.com/evermeer/EVCloudKitDao), [AlamofireJsonToObjects](https://github.com/evermeer/AlamofireJsonToObjects) and [AlamofireXmlToObjects](https://github.com/evermeer/AlamofireXmlToObjects)

## Main features of EVReflection:
- Parsing objects based on NSObject to and from a dictionary.
- Parsing objects to and from a JSON string.
- Support NSCoding methods encodeWithCoder and decodeObjectWithCoder
- Supporting Printable, Hashable and Equatable while using all properties. (Support for Set in Swift 1.2)
- Mapping objects from one type to an other

## It's easy to use:

Defining an object. You only have to set EVObject as it's base class:
```
class User: EVObject {
    var id: Int = 0
    var name: String = ""
    var friends: [User]? = []
}
```

Parsing JSON to an object:
```
let json:String = "{\"id\": 24, \"name\": \"Bob Jefferson\", \"friends\": [{\"id\": 29, \"name\": \"Jen Jackson\"}]}"
let user = User(json: json)
```

Parsing JSON to an array of objects:
```
let json:String = "[{\"id\": 27, \"name\": \"Bob Jefferson\"}, {\"id\": 29, \"name\": \"Jen Jackson\"}]"
let array = [User](json: json)
```

Parsing from and to a dictionary:
```
let dict = user.toDictionary()
let newUser = User(dictionary: dict)
XCTAssert(user == newUser, "Pass")
```

Saving and loading an object to and from a file:
```
user.saveToTemp("temp.dat")
let result = TestObject2(fileNameInTemp: "temp.dat")
XCTAssert(theObject == result, "Pass")
```

Mapping object to another type:
```
let administrator: Administrator = user.mapObjectTo()
```


## If you have XML instead of JSON

If you want to do the same but you have XML, then you can achieve that using the XMLDictionary library.[XMLDictionary](https://github.com/nicklockwood/XMLDictionary) Is a simple way to parse and generate XML. Converts an XML file to an NSDictionary. With that library your code will look like this:


```
let xml = "<user><id>27</id><name>Bob</name><friends><user><id>20</id><name>Jen</name></user></friends></user>"
let user = User(dictionary: NSDictionary(XMLString: xml))
```

## Using EVReflection in your own App 

'EVReflection' is available through the dependency manager [CocoaPods](http://cocoapods.org). 
You do have to use cocoapods version 0.36 or later

You can just add EVReflection to your workspace by adding the folowing 2 lines to your Podfile:

```
use_frameworks!
pod "EVReflection"
```

I have now moved on to Swift 2. If you want to use EVReflection, then get that version by using the podfile command:
```
use_frameworks!
pod "EVReflection", '~> 2.6'
```

Version 0.36 of cocoapods will make a dynamic framework of all the pods that you use. Because of that it's only supported in iOS 8.0 or later. When using a framework, you also have to add an import at the top of your swift file like this:

```
import EVReflection
```

If you want support for older versions than iOS 8.0, then you can also just copy the files from the pod folder to your project 


## More Sample code 
Clone EVReflection to your desktop to see these and more unit tests

```
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
```

## Extra information:

### Automatic keyword mapping for Swift keywords
If you have JSON fields that are Swift keywords, then prefix the property with an underscore. So the JSON value for self will be stored in the property _self. At this moment the folowing keywords are handled:
"self", "description", "class", "deinit", "enum", "extension", "func", "import", "init", "let", "protocol", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "do", "else", "fallthrough", "if", "in", "for", "return", "switch", "where", "while", "as", "dynamicType", "is", "new", "super", "Self", "Type", "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__", "associativity", "didSet", "get", "infix", "inout", "left", "mutating", "none", "nonmutating", "operator", "override", "postfix", "precedence", "prefix", "right", "set", "unowned", "unowned", "safe", "unowned", "unsafe", "weak", "willSet", "private", "public"

### Automatic keyword mapping PascalCase or camelCase to snake_case
When creating objects from JSON EVReflection will automatically detect if snake_case (keys are all lowercase and words are separated by an underscore) should be converted to PascalCase or camelCase property names. 

When exporting object to a dictionary or JSON string you will have an option to specify that you want a conversion to snace_case or not. The default is yes.

```
let jsonString = myObject.toJsonString(performKeyCleanup:false)
let dict = myObject.toDictionary(performKeyCleanup:false)
```


### Custom keyword mapping
It's also possible to create a custom property mapping. You can define if an import should be ignored, if an export should be ignored or you can map a property name to another key name (for the dictionary and json). For this you only need to implement the propertyMapping method in the object like this:

```
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
You can also use your own property converters. For this you need to implement the propertyConverters method in your object. For each property you can create a custom getter and setter that will then be used by EVReflection. In the sample below the JSON texts 'Sure' and 'Nah' will be converted to true or false for the property isGreat.
```
public class TestObject6: EVObject {
    var isGreat: Bool = false

    override public func propertyConverters() -> [(String?, (Any?)->(), () -> Any? )] {
        return [
            ( // We want a custom converter for the field isGreat
              "isGreat"
              // isGreat will be true if the json says 'Sure'
              , { self.isGreat = ($0 as? String == "Sure") }
              // The json will say 'Sure  if isGreat is true, otherwise it will say 'Nah'
              , { return self.isGreat ? "Sure": "Nah"})
        ]
    }
}
```

### What to do when you use object enheritance
You can deserialize json to an object that uses enheritance. When the properties are specified as the base class, then the correct specific object type will be returned by the function getSecificType. See the sample code below or the unit test in EVReflectionEnheritanceTests.swift

```
class Quz: EVObject {
    var fooArray: Array<Foo> = []
    var fooBar: Foo?
    var fooBaz: Foo?
}

class Foo: EVObject {
    var allFoo: String = "all Foo"

    // What you need to do to get the correct type for when you deserialize enherited classes
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
- generic properties like var myVal:T = T()
- structs like CGRect or CGPoint

For all these issues there are workarounds. The easiest workaround is just using a difrent type like:

- Instead of an Int? you could use NSNumber?
- Instead of [MyObject?] use [MyObject]
- Instead of 'var status: StatysType' use 'var status:Int' and save the rawValue
- Instead of a generic property use a specific property that can hold the data (a dictionary?)
- Instead of using a struct, create your own object model for that struct

If you want to keep on using the same type, You can override the setValue forUndefinedKey in the object itself. See WorkaroundsTests.swift and WorkaroundSwiftGenericsTests.swift to see the workaround for all these types in action. 

####Generic properties
For generic properties the protocol EVGenericsKVC is required. see WorkaroundSwiftGenericsTests.swift 

####Arrays with nullable objects
For arrays with nullable objects like [MyObj?] the protocol EVArrayConvertable is required. see WorkaroundsTests.swift

####Swift Dictionaries
For Swift Dictionaries (and not NSDictionary) the protocol EVDictionaryConvertable is required. See WorkaroundsTests.swift

## License

EVReflection is available under the MIT 3 license. See the LICENSE file for more info.

## My other libraries:
Also see my other open source iOS libraries:

- [EVReflection](https://github.com/evermeer/EVReflection) - Swift library with reflection functions with support for NSCoding, Printable, Hashable, Equatable and JSON 
- [EVCloudKitDao](https://github.com/evermeer/EVCloudKitDao) - Simplified access to Apple's CloudKit
- [EVFaceTracker](https://github.com/evermeer/EVFaceTracker) - Calculate the distance and angle of your device with regards to your face in order to simulate a 3D effect
- [EVURLCache](https://github.com/evermeer/EVURLCache) - a NSURLCache subclass for handling all web requests that use NSURLReques
- [AlamofireJsonToObject](https://github.com/evermeer/AlamofireJsonToObjects) - An Alamofire extension which converts JSON response data into swift objects using EVReflection
- [AlamofireXmlToObject](https://github.com/evermeer/AlamofireXmlToObjects) - An Alamofire extension which converts XML response data into swift objects using EVReflection and XMLDictionary
- [AlamofireOauth2](https://github.com/evermeer/AlamofireOauth2) - A swift implementation of OAuth2 using Alamofire
- [EVWordPressAPI](https://github.com/evermeer/EVWordPressAPI) - Swift Implementation of the WordPress (Jetpack) API using AlamofireOauth2, AlomofireJsonToObjects and EVReflection (work in progress)
- [PassportScanner](https://github.com/evermeer/PassportScanner) - Scan the MRZ code of a passport and extract the firstname, lastname, passport number, nationality, date of birth, expiration date and personal numer.
