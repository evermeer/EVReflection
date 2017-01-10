//
//  AlamofireXmlToObjects2Tests.swift
//  AlamofireXmlToObjectsTests
//
//  Created by Edwin Vermeer on 6/21/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import XCTest
import Alamofire
import Xml2Dictionary
import EVReflection


class JDBOR: EVObject {
    var __name: String?
    var _date: Date?
    var _version: String?
    var _copyright: String?
    var DisorderList: DisorderListObject?
}

class DisorderListObject: EVObject {
    var _id: NSNumber?
    var Disorder: DisorderObject?
}

class DisorderObject: EVObject {
    var OrphaNumber: NSNumber?
    var ExpertLink: LocalizedText?
    var Name: LocalizedText?
    var DisorderFlagList: DisorderFlagListObject?
}

class DisorderFlagListObject: EVObject {
    var _count: NSNumber?
    var DisorderFlag: NSNumber?
    var Label: String?
}

class LocalizedText: EVObject {
    var _lang: String?
    var __text: String?
}

class AlamofireXmlTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(JDBOR.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testResponseObject() {
        // This is an example of a functional test case.
        let URL: URLConvertible = "http://raw.githubusercontent.com/evermeer/AlamofireXmlToObjects/master/AlamofireXmlToObjectsTests/sampl2_xml"
        let expectation = self.expectation(description: "\(URL)")
        
        Alamofire.request(URL)
            .responseString { (response: DataResponse<String>) in
                print("\(response.result.value)")
            }
            .responseObject { (response: DataResponse<JDBOR>) in                
                expectation.fulfill()
                if let error = response.result.error {
                    XCTAssert(false, "ERROR: \(error.localizedDescription)")
                } else {
                    if let result = response.result.value {
                        print("\(result.description)")
                        
                    } else {
                        XCTAssert(false, "no result from service")
                    }
                }
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
}

