//
//  EVReflectionIssue204.swift
//  UnitTests
//
//  Created by Vermeer, Edwin on 21/05/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import Foundation
import XCTest
import EVReflection


class TestIssue204: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(DocumentDetails.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue204() {
        let obj = SimleEncodingDecodingObject()
        obj.firstName = "Edwin"
        obj.lastName = "Vermeer"
        obj.street = "Populierenlaan"
        obj.city = "Wieringerwaard"
        
        let json = obj.toJsonString()
        print("Encoded json = \(json)")
        let newObj = SimleEncodingDecodingObject(json: json)
        let newJson = newObj.toJsonString()
        
        let jsonCompare = "{\"firstName\":\"RWR3aW4=\",\"lastName\":\"VmVybWVlcg==\",\"street\":\"UG9wdWxpZXJlbmxhYW4=\",\"city\":\"V2llcmluZ2Vyd2FhcmQ=\"}"
        
        XCTAssertEqual(newJson, jsonCompare, "Encode string should have been the same.")
    }
    
}


class SimleEncodingDecodingObject : EVObject{
    var firstName: String?
    var lastName: String?
    var street: String?
    var city: String?
    
    override func decodePropertyValue(value: Any, key: String) -> Any {
        return (value as? String)?.base64Decoded?.string ?? value
    }
    
    override func encodePropertyValue(value: Any, key: String) -> Any {
        return (value as? String)?.base64Encoded.string ?? value
    }
}


extension String {
    var data:          Data  { return Data(utf8) }
    var base64Encoded: Data  { return data.base64EncodedData() }
    var base64Decoded: Data? { return Data(base64Encoded: self) }
}

extension Data {
    var string: String? { return String(data: self, encoding: .utf8) }
}

