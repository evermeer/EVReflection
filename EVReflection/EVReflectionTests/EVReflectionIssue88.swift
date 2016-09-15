//
//  EVReflectionIssue88.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 5/28/16.
//  Copyright © 2016 evict. All rights reserved.
//

import Foundation
import XCTest

@testable import EVReflection


class TestIssue88: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(Encoding.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testXmlNoteString() {
        let dictionary = [
            "notations" :     [
                "tied" :         [
                    [
                        "_type" : "stop",
                    ],
                    [
                        "_orientation" : "over",
                        "_type" : "start",
                    ],
                ],
            ]
        ]
        let obj = Note(dictionary: dictionary as NSDictionary)
        let str = EVReflection.description(obj)
        print(str)

        let obj2 = Note2(dictionary: dictionary as NSDictionary)
        let str2 = EVReflection.description(obj2)
        print(str2)
    }
}


class Note: EVObject {
    var notations: [Notations]?
}

class Note2: EVObject {
    var notations: [Tied]?
}


class Notations: EVObject {
    var tied: [Tied]?
}

class Tied: EVObject {
    var _type: StartStopContinueEnum = .none
    var _orientation: OrientationEnum?
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        switch key {
        case "_type":
            if let rawValue = value as? String {
                if let enumValue =  StartStopContinueEnum(rawValue: rawValue) {
                    self._type = enumValue
                }
            }
        case "_orientation":
            if let rawValue = value as? String {
                if let enumValue =  OrientationEnum(rawValue: rawValue) {
                    self._orientation = enumValue
                }
            }
        default:
            print("---> setValue for key '\(key)' should be handled.")
        }
    }
}

enum StartStopContinueEnum: String, EVRawString {
    case none = "none"
    case start = "start"
    case stop = "stop"
}

enum OrientationEnum: String, EVRawString {
    case over = "over"
    case under = "under"
}
