//
//  EVReflectionIssue285.swift
//  UnitTestsiOS
//
//  Created by Edwin Vermeer on 30-04-18.
//  Copyright © 2018 evict. All rights reserved.
//



import Foundation
import XCTest
import EVReflection


class TestIssue285: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(Device.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue285() {
        let customer = Customer()
        let device1 = Device(id: "1", name:"N", model: "M", systemName: "S", systemVersion: "V")
        customer.devices.append(device1)
        let json = customer.toJsonString()
        print("json = \(json)")
        let newCustomer = Customer(json: json)
        XCTAssertEqual(customer, newCustomer, "Should have been the same")
        XCTAssert(newCustomer.devices.count == 1, "Should have 1 device")
        XCTAssertEqual(device1, newCustomer.devices[0], "Device should be the same")
    }
}

open class Device: EVObject {
    open var id: String
    open var name: String // e.g. "My iPhone"
    open var model: String // e.g. @"iPhone", @"iPod touch"
    open var systemName: String // e.g. @"iOS"
    open var systemVersion: String // e.g. @"4.0"
    
    public required convenience init() {
        self.init(id: "", name: "", model: "", systemName: "", systemVersion: "")
    }
    
    public init (id:String, name: String, model: String, systemName: String, systemVersion: String) {
        self.id = id
        self.name = name
        self.model = model
        self.systemName = systemName
        self.systemVersion = systemVersion
    }
}
open class Customer: EVObject {
    open var id: String
    open var name: String
    open var email: String
    open var phone: String
    open var activationCode: String
    open var isActive: Bool
    open var devices: [Device]
    open var validationDate: String?
    
    public required convenience init() {
        self.init(name: "", email: "", phone: "", activationCode: "")
    }
    
    public init(name: String, email:String, phone: String, activationCode: String) {
        id = ""
        self.name = name
        self.email = email
        self.phone = phone
        self.activationCode = activationCode
        isActive = true
        devices = []
    }
}
