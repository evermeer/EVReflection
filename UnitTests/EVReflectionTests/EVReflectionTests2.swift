//
//  EVReflectionTests2.swift
//  UnitTests
//
//  Created by Vermeer, Edwin on 06/06/2017.
//  Copyright © 2017 evict. All rights reserved.
//


import XCTest
@testable import EVReflection


class EVReflectionTests2: XCTestCase {
    
    /**
     For now nothing to setUp
     */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(Comment.self)
    }
    
    /**
     For now nothing to tearDown
     */
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTemp() {
        
        let test = "[\n {\n \"status\" : \"0\",\n \"content\" : \"Shuru\",\n \"ctime\" : \"1438250556\",\n \"img\" : \"\",\n \"testuserinfo\" : {\n \"avatar\" : \"/5602503cc79de.jpg\",\n \"uid\" : \"d8b81b21c72f1177300247e2d8d88ec5\",\n \"telnum\" : \"18565280137\",\n \"is_seller\" : \"0\",\n \"sex\" : \"男\",\n \"name\" : \"\",\n \"interest\" : \"\"\n },\n \"fabric\" : null,\n \"commentid\" : \"22\",\n \"sound\" : \"\",\n \"vote\" : \"0\",\n \"isvote\" : 0,\n \"seller_card\" : null\n }\n]"
        print("\(test)")
        var comments = EVReflection.arrayFromJson(type: Comment(), json: test)
        var comments2 = [Comment](json: test)
        print(comments[0].testuserinfo?.uid ?? "")
        print(comments2[0].testuserinfo?.uid ?? "")
    }
    
    func testTemp2() {
        let test = "[\n {\n \"status\" : \"0\",\n \"content\" : \"Shuru\",\n \"ctime\" : \"1438250556\",\n \"img\" : \"\",\n \"isvote\" : 0,\n \"testuserinfo\" : {\n \"avatar\" : \"\",\n \"uid\" : \"d8b81b21c72f1177300247e2d8d88ec5\",\n \"telnum\" : \"18565280137\",\n \"is_seller\" : \"0\",\n \"sex\" : \"男\",\n \"name\" : \"\",\n \"interest\" : \"\"\n },\n \"commentid\" : \"22\",\n \"fabric\" : null,\n \"sound\" : \"\",\n \"vote\" : \"0\",\n \"seller_card\" : null\n }\n]"
        let comments = EVReflection.arrayFromJson(type: Comment(), json: test)
        print(comments[0].testuserinfo?.telnum ?? "")
    }
}

class Comment: EVObject {
    var commentid = ""
    var content = ""
    var ctime = ""
    var status = "2"
    var img = ""
    var vote = "0"
    var sound: String?
    var isvote: Bool = false
    var seller_card: String?
    var fabric: String?
    var testuserinfo: UserInfo?
}

class UserInfo: EVObject {
    var avatar = ""
    var uid = ""
    var telnum = ""
    var is_seller = "0"
    var sex = "M"
    var name = "TestUser"
    var interest = ""
}



