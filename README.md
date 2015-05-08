# EVReflection

This version is for Xcode 6.3. Travis-ci build is failing because it's running Xcode 6.1.1 Have to wait for the build to pass again when Travis-ci adds Xcode 6.3 as an option (planned for end May?)

[![Build Status](https://travis-ci.org/evermeer/EVReflection.svg?style=flat)](https://travis-ci.org/evermeer/EVReflection)
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


Run the tests in EVReflectionTests.swift to see EVReflection in action.
EVReflection is used extensively in [EVCloudKitDao](https://github.com/evermeer/EVCloudKitDao)

## Main features of EVReflection:
- Parsing objects based on NSObject to a dictionary. 
- Parsing a dictionary back to an object.
- Creating a class from a string value and get the string value for a class.
- Support NSCoding methods encodeWithCoder and decodeObjectWithCoder
- Supporting Printable, Hashable and Equatable while using all properties. (Support for Set in Swift 1.2)

## Known issues
It's not possible in Swift to use .setObjectForKey for nullable type fiels like Int?. Workaround is using NSNumber? instead or by overriding the setValue for key in the object itself (see the unit test for TestObject3)

## Using EVReflection in your own App 

'EVReflection' is now available through the dependency manager [CocoaPods](http://cocoapods.org). 
You do have to use cocoapods version 0.36. At this moment this can be installed by executing:

```
[sudo] gem install cocoapods
```

If you have installed cocoapods version 0.36 or later, then you can just add EVReflection to your workspace by adding the folowing 2 lines to your Podfile:

```
use_frameworks!
pod "EVReflection"
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


