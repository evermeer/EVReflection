//
//  EVReflectionAssociatedTests.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 11/26/15.
//  Copyright © 2015 evict. All rights reserved.
//

import Foundation
@testable import EVReflection


import XCTest

/**
 Testing EVReflection
 */
class EVReflectionAssociatedTests: XCTestCase {
    
    /**
     For now nothing to setUp
     */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(TestObject)
    }
    
    /**
     For now nothing to tearDown
     */
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testEnumAssociatedValues() {
        let parameters:[usersParameters] = [.number(19), .authors_only(false)]
        let y = WordPressRequestConvertible.MeLikes("XX", Dictionary(associated: parameters))
        // Now just extract the label and associated values from this enum
        let label = y.associated.label
        let (token, param) = y.associated.value as! (String, [String:Any]?)
        
        XCTAssertEqual("MeLikes", label, "The label of the enum should be MeLikes")
        XCTAssertEqual("XX", token, "The token associated value of the enum should be XX")
        XCTAssertEqual(19, param?["number"] as? Int, "The number param associated value of the enum should be 19")
        XCTAssertEqual(false, param?["authors_only"] as? Bool, "The authors_only param associated value of the enum should be false")
        
        print("\(label) = {token = \(token), params = \(param)")
    }

}



// See http://github.com/evermeer/EVWordPressAPI for a full functional usage of associated values
enum WordPressRequestConvertible: EVAssociated {
    case Users(String, Dictionary<String, Any>?)
    case Suggest(String, Dictionary<String, Any>?)
    case Me(String, Dictionary<String, Any>?)
    case MeLikes(String, Dictionary<String, Any>?)
    case Shortcodes(String, Dictionary<String, Any>?)
}

public enum usersParameters: EVAssociated {
    case context(String)
    case http_envelope(Bool)
    case pretty(Bool)
    case meta(String)
    case fields(String)
    case callback(String)
    case number(Int)
    case offset(Int)
    case order(String)
    case order_by(String)
    case authors_only(Bool)
    case type(String)
}