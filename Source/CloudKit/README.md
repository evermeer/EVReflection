EVReflection/CloudKit
============

This is the sub specification for a CloudKit extension for EVReflection

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
pod 'EVReflection/CloudKit'
```

# Advanced object mapping
This subspec can use all [EVReflection](https://github.com/evermeer/EVReflection) features like property mapping, converters, validators and key cleanup. See [EVReflection](https://github.com/evermeer/EVReflection) for more information.

# Usage

Create a class which has `CKDataObject` as it's base class. 

```swift
import Foundation
import EVReflection

class CloudNews: CKDataObject {
    var Subject: String = ""
    var Body: String = ""
    var ActionUrl: String = ""

    // When using a CKReference, then also store a string representation of the recordname for simplifying predecate queries that also can be used agains an object array.
    var Asset: CKReference?
    var Asset_ID: String = ""


    // Helper function for the asset
    func setAssetFields(_ asset: Asset) {
        self.Asset_ID = asset.recordID.recordName
        self.Asset = CKReference(recordID: CKRecordID(recordName: asset.recordID.recordName), action: CKReferenceAction.none)
    }
}

// It's adviced to store your assets in a seperate table
class Asset: CKDataObject {
    var File: CKAsset?
    var FileName: String = ""
    var FileType: String = ""

    // Helper initialisation function
    convenience init(name: String, type: String, url: URL) {
        self.init()
        FileName = name
        FileType = type
        File = CKAsset(fileURL: url)
    }
}
```

You can then map these objects to a CKRecord and back with code like this:
```swift
// A news object
let news = CloudNews()
news.Subject = "the title"
news.Body = "The body text"
news.ActionUrl = "https://github.com/evermeer"

// Add an image asset
if let path = Bundle(for: CloudKitTests.self).path(forResource: "coverage", ofType: "png") {
    let asset = Asset(name: "coverage", type: "png", url: URL(fileURLWithPath: path))
    news.setAssetFields(asset)

    let myImage: UIImage? = asset.File?.image()
    XCTAssertNotNil(myImage, "Image was not set")
} else {
    XCTAssert(false, "Could not find resource coverage.png")
}

let record1 = news.toCKRecord()
print ("\(record1)")

let record2 = CKRecord(news)
print ("\(record2)")

let newNews1 = CloudNews(record1)
print(newNews1)

let newNews2 = record2!.toDataObject()
print("\(newNews2)")

```

The code above does use this Extension
```swift
import CloudKit
import UIKit

public extension CKAsset {
    public func image() -> UIImage? {
        if let data = try? Data(contentsOf: self.fileURL) {
            return UIImage(data: data)
        }
        return nil
    }
}
```

