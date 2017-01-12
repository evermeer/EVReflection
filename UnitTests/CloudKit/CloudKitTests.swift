//
//  CloudKitTests.swift
//  UnitTests
//
//  Created by Edwin Vermeer on 12/01/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import XCTest
import CloudKit
@testable import EVReflection

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
        let news = CloudNews()
        news.Title = "the title"
        news.Text = "The text"
        let record1 = news.toCKRecord()
        print ("\(record1)")
        
        let record2 = CKRecord(news)
        print ("\(record2)")
        
        let newNews1 = CKDataObject(record1)
        print(newNews1)
        
        let newNews2 = record2!.toDataObject()
        print("\(newNews2)")
    }
}

class CloudNews: CKDataObject {
    var Title: String?
    var Text: String?
}
