//
//  CloudKitTests.swift
//  UnitTests
//
//  Created by Edwin Vermeer on 12/01/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import XCTest
import CloudKit
import EVReflection

class CloudNews: CKDataObject {
    var Subject: String = ""
    var Body: String = ""
    var ActionUrl: String = ""
    
    // When using a CKReference, then also store a string representation of the recordname for simplifying predecate queries that also can be used agains an object array.
    var Asset: CKReference?
    var Asset_ID: String = ""
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
    
    convenience init(name: String, type: String, url: URL) {
        self.init()
        FileName = name
        FileType = type
        File = CKAsset(fileURL: url)
    }
}


/**
 Testing EVReflection
 */
class CloudKitTests: XCTestCase {
    
    /**
     For now nothing to setUp
     */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(TestObject.self)
    }
    
    /**
     For now nothing to tearDown
     */
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /**
     Get the string name for a class and then generate a class based on that string
     */
    func testCloudkitSmokeTest() {
        // A news object
        let news = CloudNews(json: "{\"subject\":\"The title\",\"body\":\"The body text\",\"actionUrl\":\"https://github.com/evermeer\"}")
        
        // Add an image asset
        if let path = Bundle(for: CloudKitTests.self).path(forResource: "coverage", ofType: "png") {
            let asset = Asset(name: "coverage", type: "png", url: URL(fileURLWithPath: path))
            news.setAssetFields(asset)

            #if os(iOS)
                let myImage: UIImage? = asset.File?.image()
                XCTAssertNotNil(myImage, "Image was not set")
            #endif
        } else {
            XCTAssert(false, "Could not find resource coverage.png")
        }
        
        let record1 = news.toCKRecord()
        print ("\(record1)")
        
        let record2 = CKRecord(news)
        print ("\(record2?.description ?? "")")
        
        let newNews1 = CloudNews(record1)
        print(newNews1)
        
        let newNews2 = record2!.toDataObject()
        print("\(newNews2?.description ?? "")")
        
        let json = news.toJsonString()
        let newNews3 = CloudNews(json: json)
        print (newNews3)
    }
}

