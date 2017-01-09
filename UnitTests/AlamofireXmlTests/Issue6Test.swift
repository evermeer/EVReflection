//
//  Issue6Test.swift
//  AlamofireXmlToObjects
//
//  Created by Edwin Vermeer on 9/8/16.
//  Copyright © 2016 evict. All rights reserved.
//



import XCTest
import Alamofire
import XMLDictionary
import EVReflection



class Issue6Test: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(HMChannel.self)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testIssue() {
        // This is an example of a functional test case.
        let URL: URLConvertible = "http://raw.githubusercontent.com/evermeer/AlamofireXmlToObjects/master/AlamofireXmlToObjectsTests/Issue6_xml"
        let expectation = self.expectation(description: "\(URL)")

        Alamofire.request(URL)
            .responseObject { (response: DataResponse<XMLResult>) in
                if let error = response.result.error {
                    XCTAssert(false, "ERROR: \(error.localizedDescription)")
                } else {
                    if let result = response.result.value {
                        print("\(result.description)")

                    } else {
                        XCTAssert(false, "no result from service")
                    }
                }
                expectation.fulfill()
        }

        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error)")
        }
    }
}


class XMLResult: EVObject {
    var name: String?
    var channel: [HMChannel]?
    var datapoint: [HMDatapoint]?

    override internal func propertyMapping() -> [(String?, String?)] {
        return [("name", "__name")]
    }
}

class HMChannel: EVObject {
    var datapoint: [HMDatapoint] = [HMDatapoint]()
    var name: String = ""
    var ise_id: Int = 0
    var address: String = ""
    var group_partner: String = ""
    var type: String = ""
    var ready_config: String = ""
    var interface: String = ""
    var device_type: String = ""
    var visible: String = ""
    var aes_available: String = ""
    var direction: String = ""
    var parent_device: String = ""
    var index: String = ""
    var operate: String = ""
    var transmission_mode: String = ""

    override internal func propertyMapping() -> [(String?, String?)] {
        return [("name", "_name"), ("ise_id", "_ise_id"), ("device_type", "_device_type"), ("address", "_address"), ("group_partner", "_group_partner"), ("type", "_type"), ("ready_config", "_ready_config"), ("interface", "_interface"), ("visible", "_visible"), ("aes_available", "_aes_available"), ("direction", "_direction"), ("parent_device", "_parent_device"), ("index", "_index"), ("operate", "_operate"), ("transmission_mode", "_transmission_mode")]
    }
}

class HMDatapoint: EVObject {
    var name: String?
    var type: String?
    var ise_id: Int = 0
    var value: String?
    var valuetype: String?
    var valueunit: String?
    var timestamp: Int = 0
    var operations: String?

    override internal func propertyMapping() -> [(String?, String?)] {
        return [("name", "_name"), ("ise_id", "_ise_id"), ("type", "_type"), ("value", "_value"), ("valuetype", "_valuetype"), ("valueunit","_valueunit"), ("timestamp","_timestamp"), ("operations","_operations")]
    }
}
