//
//  EVReflectionIssue223.swift
//  UnitTests
//
//  Created by Vermeer, Edwin on 02/09/2017.
//  Copyright © 2017 evict. All rights reserved.
//


import Foundation
import XCTest
import EVReflection


class TestIssue223: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(DocumentDetails.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue223() {
        let json = "{\"created\":\"invalid date data\"}"
        let obj = TestDate(json: json)
        print("obj = \(obj)")
    }
    
}


class TestDate : EVObject{
    var dateCreated: Date?
    
    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [(keyInObject: "dateCreated", keyInResource: "created")]
    }
    
    override func decodePropertyValue(value: Any, key: String) -> Any? {
        if key == "dateCreated" {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ssZ"
            let date: Any? = dateFormatter.date(from: value as? String ?? "")
            return date
        }
        return value
    }
}

