//
//  EVReflectionIssue124.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 9/19/16.
//  Copyright © 2016 evict. All rights reserved.
//


import Foundation
import XCTest
@testable import EVReflection

class TestIssue124: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(MoreSection.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue124() {
        if let path = Bundle(for: type(of: self)).path(forResource: "EVReflectionIssue124", ofType: "plist") {
            if let data = NSDictionary(contentsOfFile: path) {
                let plistObject = Wrapper(dictionary: data)
                print(plistObject)
            }
        }        
    }
}


class Wrapper: EVObject {
    var data: [MoreSection]?
}

class MoreSection: EVObject {
    var SectionOrder: NSNumber?
    var values: [MoreObject]?
}

class MoreObject: EVObject {
    var name: String!
    var imgName: String!
    var sort_order: String!
    var segueName: String!
    var isEnabled: NSNumber!
}
