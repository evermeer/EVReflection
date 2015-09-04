# EVReflection

[![Circle CI](https://img.shields.io/circleci/project/evermeer/EVReflection.svg?style=flat)](https://circleci.com/gh/evermeer/EVReflection)
[![Issues](https://img.shields.io/github/issues-raw/evermeer/EVReflection.svg?style=flat)](https://github.com/evermeer/EVReflection/issues)
[![Stars](https://img.shields.io/github/stars/evermeer/EVReflection.svg?style=flat)](https://github.com/evermeer/EVReflection/stargazers)
[![Version](https://img.shields.io/cocoapods/v/EVReflection.svg?style=flat)](http://cocoadocs.org/docsets/EVReflection)
[![License](https://img.shields.io/cocoapods/l/EVReflection.svg?style=flat)](http://cocoadocs.org/docsets/EVReflection)
[![Platform](https://img.shields.io/cocoapods/p/EVReflection.svg?style=flat)](http://cocoadocs.org/docsets/EVReflection)
[![Documentation](https://img.shields.io/badge/documented-100%-brightgreen.svg?style=flat)](http://cocoadocs.org/docsets/EVReflection)

[![Git](https://img.shields.io/badge/GitHub-evermeer-blue.svg?style=flat)](https://github.com/evermeer)
[![Twitter](https://img.shields.io/badge/twitter-@evermeer-blue.svg?style=flat)](http://twitter.com/evermeer)
[![LinkedIn](https://img.shields.io/badge/linkedin-Edwin Vermeer-blue.svg?style=flat)](http://nl.linkedin.com/in/evermeer/en)
[![Website](https://img.shields.io/badge/website-evict.nl-blue.svg?style=flat)](http://evict.nl)
[![eMail](https://img.shields.io/badge/email-edwin@evict.nl-blue.svg?style=flat)](mailto:edwin@evict.nl?SUBJECT=About EVReflection)


Run the unit tests to see EVReflection in action.

EVReflection is used extensively in [EVCloudKitDao](https://github.com/evermeer/EVCloudKitDao) and [AlamofireJsonToObjects](https://github.com/evermeer/AlamofireJsonToObjects)

## Main features of EVReflection:
- Parsing objects based on NSObject to a dictionary. 
- Parsing a dictionary back to an object.
- Creating a class from a string value and get the string value for a class.
- Support NSCoding methods encodeWithCoder and decodeObjectWithCoder
- Supporting Printable, Hashable and Equatable while using all properties. (Support for Set in Swift 1.2)
- Parse an object to a JSON string and parse a JSON string to an object

## it's easy to use:

Defining an object. You only have to set NSObject as it's base class:
```
class User: NSObject {
    var id: Int = 0
    var name: String = ""
    var friends: [User]? = []
}
```

Parsing JSON to an object:
```
let json:String = "{\"id\": 24, \"name\": \"Bob Jefferson\" \"friends\": {[{\"id\": 29, \"name\": \"Jen Jackson\"}]}}"
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
```

## Using EVReflection in your own App 

'EVReflection' is available through the dependency manager [CocoaPods](http://cocoapods.org). 
You do have to use cocoapods version 0.36 or later

You can just add EVReflection to your workspace by adding the folowing 2 lines to your Podfile:

```
use_frameworks!
pod "EVReflection"
```

At the moment that is a Swift 1.2 version. When Swift 2 is released the Swift 2 branch will be merged to the trunk. If you want to keep on using the Swift 1.2 version, than use the Swift1.2 branch:
```
use_frameworks!
pod 'EVReflection', :git => 'https://github.com/evermeer/EVReflection.git', :branch => 'Swift1.2'
```

If you want to start using Swift 2.0 now (tested with beta 6) then use the Swift2 branch
```
use_frameworks!
pod 'EVReflection', :git => 'https://github.com/evermeer/EVReflection.git', :branch => 'Swift2'
```

Version 0.36 of cocoapods will make a dynamic framework of all the pods that you use. Because of that it's only supported in iOS 8.0 or later. When using a framework, you also have to add an import at the top of your swift file like this:

```
import EVReflection
```

If you want support for older versions than iOS 8.0, then you can also just copy the files from the pod folder to your project 


## More Sample code (Clone EVReflection to your desktop and see the unit tests)
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

func testNSCoding() {
    var theObject = TestObject2()
    theObject.objectValue = "value1"

    let fileDirectory =  (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString)
    var filePath = fileDirectory.stringByAppendingPathComponent("temp.dat")

    // Write the object to a file
    NSKeyedArchiver.archiveRootObject(theObject, toFile: filePath)

    // Read the object from the file
    var result = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! TestObject2

    // Are those objects the same
    XCTAssert(theObject == result, "Pass")
}
```

## Extra information:

### Automatic keyword mapping
If you have JSON fields that are Swift keywords, then prefix the property with an underscore. So the JSON value for self will be stored in the property _self. At this moment the folowing keywords are handled:
"self", "description", "class", "deinit", "enum", "extension", "func", "import", "init", "let", "protocol", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "do", "else", "fallthrough", "if", "in", "for", "return", "switch", "where", "while", "as", "dynamicType", "is", "new", "super", "Self", "Type", "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__", "associativity", "didSet", "get", "infix", "inout", "left", "mutating", "none", "nonmutating", "operator", "override", "postfix", "precedence", "prefix", "right", "set", "unowned", "unowned", "safe", "unowned", "unsafe", "weak", "willSet", "private", "public"

### Custom keyword mapping
It's also possibe to create a custom property mapping. You can define if an import should be ignored, if an export should be ignored or you can map a property name to another key name (for the dictionary and json). For this you only need to implement the propertyMapping method in the object like this:

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

### When to use EVObject instead of NSObject as a base class.
There is some functionality that could not be added as an extension to NSObject. For this the EVObject class can be used. Use EVObject in the folowing situations:

- When using NSCoding
- When executing an objects .isEqual when you want to test all properties. As an alternative you could just use == or !=
- When you expect there will be keys in your dictionary or json while there will be no property where the value can be mapped to. Instead of using EVObject you can also implement the setValue forUndefinedKey yourself.

### Known issues
EVReflection is trying to handle all types. With some types there are limitations in Swift. So far there is a workaround for any of these limitations. Here is an overview:

####It's not possible in Swift to use .setObjectForKey for:
- nullable type fields like Int? 
- properties based on an enum
- an Array of nullable objects like [MyObject?] 
- generic properties like var myVal:T = T()

For all these issues there are workarounds. The easiest workaround is just using a difrent type like:

- Instead of an Int? you could use NSNumber?
- Instead of [MyObject?] use [MyObject]
- Instead of 'var status: StatysType' use 'var status:Int' and save the rawValue
- Instead of a generic property use a specific property that can hold the data (a dictionary?)

If you want to keep on using the same type, You can override the setValue forUndefinedKey in the object itself. See WorkaroundsTests.swift and WorkaroundSwiftGenericsTests.swift to see the workaround for all these types in action. 

####Generic properties
For generic properties the protocol EVGenericsKVC is required. see WorkaroundSwiftGenericsTests.swift 

####Arrays with nullable objects
For arrays with nullable objects like [MyObj?] the protocol EVArrayConvertable is required. see WorkaroundsTests.swift

### See also:
There is also an Alamofire convenience extension for dirctly parsing the JSON to objects
See [AlamofireJsonToObjects](https://github.com/evermeer/AlamofireJsonToObjects)


