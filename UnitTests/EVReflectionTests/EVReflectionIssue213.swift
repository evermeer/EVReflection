//
//  EVReflectionIssue213.swift
//  UnitTestsiOS
//
//  Created by Vermeer, Edwin on 28/06/2017.
//  Copyright © 2017 evict. All rights reserved.
//


import Foundation
import XCTest
import EVReflection


class TestIssue213: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(Spot.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue213() {
        let path: String = Bundle(for: type(of: self)).path(forResource: "EVReflectionIssue213", ofType: "json") ?? ""
        let content = try! String(contentsOfFile: path)
        let data = ResultArrayWrapper<Spot>(json: content)
        print("\(data)")
    }
    
}


class ResultArrayWrapper<T: Model>: EVObject, EVGenericsKVC {
    required init() {
        super.init()
    }
    var data: [T]?
    
    func setGenericValue(_ value: AnyObject!, forUndefinedKey key: String) {
        switch key {
        case "data":
            data = value as? [T]
            break;
        case "meta":
            
            break;
            
        default:
            print("---> setValue '\(value)' for key '\(key)' should be handled.")
        }
    }
    
    func getGenericType() -> NSObject {
        return T() as NSObject
    }
}

class XMeta<T: Model>: Model, EVGenericsKVC {
    required init() {
        super.init()
    }
    
    var cursor: String?
    
    internal func setGenericValue(_ value: AnyObject!, forUndefinedKey key: String) {
        if(key == "data") {
            //data = value  as? [T]
        }
    }
    
    internal func getGenericType() -> NSObject {
        return T() as NSObject
    }
}

class Model: EVObject {
    
}

class Spot: Model {
    var id: String?
    var firstName: String?
    var lastName: String?
    var username: String?
    var email: String?
    var phone: String?
    var sex: String?
    var canBook: Bool = false
    var contractable: Bool = false
    
    var profile = ResultArrayWrapper<Profile>()
}

class Profile: Model {
    var about: String?
    var avatarUrl: String?
    var coverUrl: String?
}

