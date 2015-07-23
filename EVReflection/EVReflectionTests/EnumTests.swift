//
//  EnumTests.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 7/23/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import UIKit
import XCTest


/**
Testing EVReflection
*/
class EnumTests: XCTestCase {
    func testJsonUser() {
        let json:String = "{\"status\": 0}"
        let status = StatusInfo(json: json)
        XCTAssertTrue(status.status == .NotOK, "the status should be NotOK")
    }
}

class StatusInfo: EVObject {
    enum StatusType: Int {
        case NotOK = 0
        case OK
    }
    
    var status: StatusType = .OK
    
    override func setValue(value: AnyObject!, forUndefinedKey key: String) {
        switch key {
        case "status":
            if let rawValue = value as? Int {
                status = StatusType(rawValue: rawValue)!
            }
        default:
            NSLog("---> setValue for key '\(key)' should be handled.")
        }
    }

}