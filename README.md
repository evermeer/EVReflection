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

## Known issues
It's not possible in Swift to use .setObjectForKey for:
- nullable type fields like Int? 
- properties based on an enum
- an Array of nullable objects like [MyObject?] 

There are 2 possible workarounds for this.

1. Using a difrent type like:

- Instead of an Int? you could use NSNumber?
- Instead of [MyObject?] use [MyObject]
- Instead of 'var status: StatysType' use 'var status:Int' and save the rawValue

2. By overriding the setValue for key in the object itself (see WorkaroundsTests.swift to see the workaround for all these types in action)

## Using EVReflection in your own App 

'EVReflection' is now available through the dependency manager [CocoaPods](http://cocoapods.org). 
You do have to use cocoapods version 0.36 or later

You can just add EVReflection to your workspace by adding the folowing 2 lines to your Podfile:

```
use_frameworks!
pod "EVReflection"
```

If you are using Swift 2.0 (tested with beta 2) then instead put the folowing lines in your Podfile:

```
use_frameworks!
pod 'EVReflection', :git => 'https://github.com/evermeer/EVReflection.git', :branch => 'Swift2'
```

Version 0.36 of cocoapods will make a dynamic framework of all the pods that you use. Because of that it's only supported in iOS 8.0 or later. When using a framework, you also have to add an import at the top of your swift file like this:

```
import EVReflection
```

If you want support for older versions than iOS 8.0, then you can also just copy the EVReflection.swift and EVObject.swift to your app. 


## Sample code

```
public class TestObject:NSObject {
var objectValue:String = ""
}

public class TestObject2:EVObject {
var objectValue:String = ""    
}
```

```
class EVReflectionTests: XCTestCase {

    func testClassToAndFromString() {
        var theObject = TestObject()
        var theObjectString:String = EVReflection.swiftStringFromClass(theObject)
        NSLog("swiftStringFromClass = \(theObjectString)")
        if var nsobject = EVReflection.swiftClassFromString(theObjectString) {
            NSLog("object = \(nsobject)")
            XCTAssert(true, "Pass")
        } else {
            XCTAssert(false, "Fail")
        }
    }

    func testClassToAndFromDictionary() {
        var theObject = TestObject()
        var theObjectString:String = EVReflection.swiftStringFromClass(theObject)
        theObject.objectValue = "testing"
        var toDict = EVReflection.toDictionary(theObject)
        NSLog("toDictionary = \(toDict)")
        if var nsobject = EVReflection.fromDictionary(toDict, anyobjectTypeString: theObjectString) as? TestObject {
            NSLog("object = \(nsobject), objectValue = \(nsobject.objectValue)")
            XCTAssert(true, "Pass")
        } else {
            XCTAssert(false, "Fail")
        }
    }

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

    func testClassToAndFromDictionaryConvenienceMethods() {
        var theObject = TestObject2()
        theObject.objectValue = "testing"
        var toDict = theObject.toDictionary()
        NSLog("toDictionary = \(toDict)")
        var result = TestObject2(dictionary: toDict)
        XCTAssert(theObject == result, "Pass")
    }

}
```

There is now also support for JSON. Parsing JSON from and to objects is now as easy as:

```
class User: EVObject {
    var id: Int = 0
    var name: String = ""
    var email: String?
    var company: Company?
    var friends: [User] = []
}

class Company: EVObject {
    var name: String = ""
    var address: String?
}

class EVReflectionJsonTests: XCTestCase {
    func testJsonArray() {
        let jsonDictOriginal:String = "[{\"id\": 27, \"name\": \"Bob Jefferson\"}, {\"id\": 29, \"name\": \"Jen Jackson\"}]"
        let array:[User] = EVReflection.arrayFromJson(User(), json: jsonDictOriginal)
        print("Object array from json string: \n\(array)\n\n")
        XCTAssertTrue(array.count == 2, "should have 2 Users")
        XCTAssertTrue(array[0].id == 27, "id should have been set to 27")
        XCTAssertTrue(array[0].name == "Bob Jefferson", "name should have been set to Bob Jefferson")
        XCTAssertTrue(array[1].id == 29, "id should have been set to 29")
        XCTAssertTrue(array[1].name == "Jen Jackson", "name should have been set to Jen Jackson")
    }

    func testJsonObject(){
        let jsonDictOriginal = [
            "id": 24,
            "name": "John Appleseed",
            "email": "john@appleseed.com",
            "company": [
                "name": "Apple",
                "address": "1 Infinite Loop, Cupertino, CA"
            ],
            "friends": [
                ["id": 27, "name": "Bob Jefferson"],
                ["id": 29, "name": "Jen Jackson"]
            ]
        ]
        print("Initial dictionary:\n\(jsonDictOriginal)\n\n")

        let userOriginal = User(dictionary: jsonDictOriginal)
        validateUser(userOriginal)

        let jsonString = userOriginal.toJsonString()
        print("JSON string from dictionary: \n\(jsonString)\n\n")

        let userRegenerated = User(json:jsonString)
        validateUser(userRegenerated)

        if userOriginal == userRegenerated {
            XCTAssert(true, "Success")
        } else {
            XCTAssert(false, "Faileure")
        }
    }

    func validateUser(user:User) {
        print("Validate user: \n\(user)\n\n")
        XCTAssertTrue(user.id == 24, "id should have been set to 24")
        XCTAssertTrue(user.name == "John Appleseed", "name should have been set to John Appleseed")
        XCTAssertTrue(user.email == "john@appleseed.com", "email should have been set to john@appleseed.com")

        XCTAssertNotNil(user.company, "company should not be nil")
        print("company = \(user.company)\n")
        XCTAssertTrue(user.company?.name == "Apple", "company name should have been set to Apple")
        print("company name = \(user.company?.name)\n")
        XCTAssertTrue(user.company?.address == "1 Infinite Loop, Cupertino, CA", "company address should have been set to 1 Infinite Loop, Cupertino, CA")

        XCTAssertNotNil(user.friends, "friends should not be nil")
        XCTAssertTrue(user.friends.count == 2, "friends should have 2 Users")

        if user.friends.count == 2 {
            XCTAssertTrue(user.friends[0].id == 27, "friend 1 id should be 27")
            XCTAssertTrue(user.friends[0].name == "Bob Jefferson", "friend 1 name should be Bob Jefferson")
            XCTAssertTrue(user.friends[1].id == 29, "friend 2 id should be 29")
            XCTAssertTrue(user.friends[1].name == "Jen Jackson", "friend 2 name should be Jen Jackson")            
        }
    }
}
```

If you have JSON fields that are Swift keywords, then prefix the property with an underscore. So the JSON value for self will be stored in the property _self. At this moment the folowing keywords are handled:

"self", "description", "class", "deinit", "enum", "extension", "func", "import", "init", "let", "protocol", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "do", "else", "fallthrough", "if", "in", "for", "return", "switch", "where", "while", "as", "dynamicType", "is", "new", "super", "Self", "Type", "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__", "associativity", "didSet", "get", "infix", "inout", "left", "mutating", "none", "nonmutating", "operator", "override", "postfix", "precedence", "prefix", "right", "set", "unowned", "unowned", "safe", "unowned", "unsafe", "weak", "willSet"

See also [AlamofireJsonToObjects](https://github.com/evermeer/AlamofireJsonToObjects)



