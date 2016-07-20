//
//  EVReflectionIssue107.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 7/20/16.
//  Copyright © 2016 evict. All rights reserved.
//


import Foundation
import XCTest
@testable import EVReflection

class TestIssue107: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(Message)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue107() {
        let dataList = "[{" +
            "    \"Cities\" :  [\"CityA\"]," +
            "    \"ConfigName\" : \"Config0\"," +
            "    \"Configurations\" :             {" +
            "        \"desc\" : \"Desc2\"," +
            "        \"evening\" : \"Evening\"," +
            "        \"morning\" : \"Morning\"," +
            "    }" +
            "}," +
            "{" +
            "    \"Cities\" : [\"\"]," +
            "    \"ConfigName\" : \"Config1\"," +
            "    \"Configurations\" :             {" +
            "        \"desc\" : \"Desc\"" +
            "    }" +
            "}]"
        
        let c = [EVAPIConfigurationModel](json: dataList)
        print(c)
        
        for i:EVAPIConfigurationModel in c {
            if let conf: EVSubConfigurationModel = i.Configurations {
                print("Errors: \(conf.evReflectionStatuses)")
            }
        }
    }
    
}

class EVAPIConfigurationModel: EVObject {
    var ConfigName: String?
    var Configurations: EVSubConfigurationModel?
    var Cities: [String]?
}

class EVSubConfigurationModel: EVObject {
    var desc: String?
    var evening: String?
    var morning: String?
    
    override internal func initValidation(dict: NSDictionary) {
        self.initMayNotContainKeys(["desc","morning","evening"], dict: dict)
    }
}
