//
//  EVReflectionIssue202.swift
//  UnitTests
//
//  Created by Vermeer, Edwin on 21/05/2017.
//  Copyright © 2017 evict. All rights reserved.
//



import Foundation
import XCTest
import EVReflection


class TestIssue202: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(DocumentDetails.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue202() {
        let json = "{\"chartConfigs\":{\"config_id\":\"651c3f71-3d44-11e7-b0b9-276d909080a8\",\"autorefresh\":false,\"background\":{\"0\":{\"background_color\":\"#feffea\",\"border_color\":\"#3264c8\",\"border_width\":2.0,\"inner_radius\":0.0,\"outer_radius\":0.0,\"shape\":\"\"}},\"chart_type\":\"Column and Bar Chart/Column with rotated labels\"}}"
        let obj = ChartConfigPojo(json: json, forKeyPath: "chartConfigs")
        print("obj = \(obj)")
        
        XCTAssert(obj.background?.count == 1, "Should have 1 background object")
        let bg = obj.background?["0"]
        XCTAssertNotNil(bg, "Should have a background object")
        XCTAssert(bg?.background_color ?? "" == "#feffea", "Should have #feffea background color")
    }
    
}


class BackgroundPOJO : EVObject{
    var background_color: String?
    var border_color: String?
    var border_width: Float = 0.0
    var inner_radius: Float = 0.0
    var outer_radius: Float = 0.0
    var shape: String?
}

class ChartConfigPojo : EVObject{
    var config_id: String?
    var autorefresh: Bool = false
    var background : [String:BackgroundPOJO]?
    var chart_type: String?
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        switch key {
        case "background":
            background = [:]
            if let dict = value as? NSDictionary{
                for (key,val) in dict {
                    let k = Int(key as? String ?? "-1") ?? -1
                    print("key = \(k), value = \(val)")
                    if let val = val as? NSDictionary {
                        self.background?["\(k)"] = BackgroundPOJO(dictionary: val)
                    }
                }
            }
        default:
            print("unhandled key \(key))")
        }
    }
}
