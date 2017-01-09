//
//  EVReflectionIssue110.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 7/28/16.
//  Copyright © 2016 evict. All rights reserved.
//


import Foundation
import XCTest
@testable import EVReflection

class TestIssue110: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(Message.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue110() {
        let a = TestSet()
        a.Cities.insert("Amsterdam")
        print(a)
        
        let dataList = "{" +
            "    \"Cities\" :  [\"CityA\"]," +
            "    \"Name\" : \"test1\"," +
        "}"
        
        let c = TestSet(json: dataList)
        print(c)
    }
    
}

class TestSet: EVObject, EVArrayConvertable {
    var Name: String?
    var Cities: Set<String> = Set<String>()
    
    // Implementation of the EVArrayConvertable protocol for handling a Set.
    func convertArray(_ key: String, array: Any) -> NSArray {
        assert(key == "Cities", "convertArray for key \(key) should be handled.")
        
        let returnArray = NSMutableArray()
        if key == "Cities" {
            for item in (array as? Set<String>) ?? Set<String>() {
                returnArray.add(item)
            }
        }
        return returnArray
    }
}
