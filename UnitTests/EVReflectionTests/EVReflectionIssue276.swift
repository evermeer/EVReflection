//
//  EVReflectionIssue176.swift
//  UnitTests
//
//  Created by Edwin Vermeer on 29-03-18.
//  Copyright © 2018 evict. All rights reserved.
//


import Foundation
import XCTest
import EVReflection


class TestIssue276: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(DocumentDetails.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDoesNotConvertPasswordsNStuff() {
        let user = User276()
        user.password = "ohNoz"
        let dict = user.toDictionary()
        print(dict)
    }
}


class User276: EVObject {
    var walletId: String?
    var modifiedBy: String?
    var emailAddress: String?
    var id: String?
    var active: String?
    var created: String?
    var lastModified: String?
    var fullName: String?
    var phoneNumber: String?
    // swiftlint:disable:next identifier_name
    var _description: String?
    var password: String?
    
    override public func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [(keyInObject: "password",keyInResource: nil)]
    }
}
