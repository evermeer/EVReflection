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
            .responseObjectFromXML { (response: DataResponse<XMLResult>) in
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

    override internal func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [(keyInObject: "name", keyInResource: "__name")]
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

    override internal func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [(keyInObject: "name", keyInResource: "_name"),
                (keyInObject: "ise_id", keyInResource:"_ise_id"),
                (keyInObject: "device_type", keyInResource: "_device_type"),
                (keyInObject: "address", keyInResource: "_address"),
                (keyInObject: "group_partner", keyInResource: "_group_partner"),
                (keyInObject: "type", keyInResource: "_type"),
                (keyInObject: "ready_config", keyInResource: "_ready_config"),
                (keyInObject: "interface", keyInResource: "_interface"),
                (keyInObject: "visible", keyInResource: "_visible"),
                (keyInObject: "aes_available", keyInResource: "_aes_available"),
                (keyInObject: "direction", keyInResource: "_direction"),
                (keyInObject: "parent_device", keyInResource: "_parent_device"),
                (keyInObject: "index", keyInResource: "_index"),
                (keyInObject: "operate", keyInResource: "_operate"),
                (keyInObject: "transmission_mode", keyInResource: "_transmission_mode")]
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

    override internal func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [(keyInObject: "name", keyInResource: "_name"),
                (keyInObject: "ise_id", keyInResource: "_ise_id"),
                (keyInObject: "type", keyInResource: "_type"),
                (keyInObject: "value", keyInResource: "_value"),
                (keyInObject: "valuetype", keyInResource: "_valuetype"),
                (keyInObject: "valueunit", keyInResource: "_valueunit"),
                (keyInObject: "timestamp", keyInResource: "_timestamp"),
                (keyInObject: "operations", keyInResource: "_operations")]
    }
}
