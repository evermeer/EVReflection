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
        EVReflection.setBundleIdentifier(EVDataListContainerModel.self)
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
        
        for i: EVAPIConfigurationModel in c {
            if let conf: EVSubConfigurationModel = i.Configurations {
                print("Errors: \(conf.evReflectionStatuses)")
            }
        }
    }
    
    func testIssue107b() {
        let json = "{" +
            "\"dataList\": [" +
            "{" +
            "    \"Unique\": \"1300001020\"," +
            "    \"Description\": \"E08-017\"," +
            "    \"Street\": \"Emmalaan\"," +
            "    \"HouseNumber\": \"1000\"," +
            "    \"City\": \"Emmen\"," +
            "    \"ReportCategory\": \"3000000717\"," +
            "    \"ContainerSpotList\": [" +
            "        {" +
            "        \"Unique\": \"A11\"," +
            "        \"Code\": \"A11\"," +
            "        \"Description\": \"Restafval Emmen\"," +
            "        \"ContainerList\": [" +
            "            {" +
            "            \"Unique\": \"1000000225\"," +
            "            \"Code\": \"8017\"," +
            "            \"Description\": \" \"," +
            "            \"ReportCategory\": null" +
            "            } ]" +
            "        } ]" +
            "    }" +
            "]," +
            "\"data\": null," +
            "\"status\": true," +
            "\"messageCode\": 107," +
            "\"token\": null," +
            "\"ID\": null," +
            "\"invalidParameters\": null," +
            "\"total\": 0" +
            "}"
        let data = EVDataListContainerModel(json: json)
        print(data)
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
    
    override internal func initValidation(_ dict: NSDictionary) {
        self.initMayNotContainKeys(["desc","morning","evening"], dict: dict)
    }
}

class EVDataListContainerModel: EVObject {
    var DataList: [EVListDistrictContainerModel] = []
}

class EVListDistrictContainerModel: EVObject {
    var Unique: String?
    var Description: String?
    var Street: String?
    var HouseNumber: String?
    var City: String?
    var ReportCategory: String?
    var ContainerSpotList: [EVContainerSpotListModel] = [EVContainerSpotListModel]()
}


class EVContainerSpotListModel: EVObject {
    var Unique: String?
    var Code: String?
    var Description: String?
    var ContainerList: [EVContainerListModel] = [EVContainerListModel]()
    
}

class EVContainerListModel: EVObject {
    var Unique: String?
    var Code: String?
    var Description: String?
    var ReportCategory: String? = ""
}
