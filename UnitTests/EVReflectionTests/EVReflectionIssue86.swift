//
//  EVReflectionIssue86.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 5/23/16.
//  Copyright © 2016 evict. All rights reserved.
//

import Foundation
import XCTest

@testable import EVReflection


class TestIssue86: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(Encoding.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let dictionary = [
            "__name": "encoding",
            "encodingDate": "2011-08-08",
            "software": [
                "Finale 2011 for Windows",
                "Dolet 6.0 for Finale"
            ],
            "supports": [
                [
                    "_attribute": "new-system",
                    "_element": "print",
                    "_type": "yes",
                    "_value": "yes",
                ],
                [
                    "_attribute": "new-page",
                    "_element": "print",
                    "_type": "yes",
                    "_value": "yes",
                ]
            ]
        ] as [String : Any]
        
        print(dictionary)
        
        let obj = Encoding(dictionary: dictionary as NSDictionary)
        
        print(EVReflection.description(obj))
    }
}



class Encoding: EVObject {
    var __name: String = ""
    var encodingDate: String?
    var Xsoftware: [Software]?
    var supports: [Supports]?

    internal override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "software" {
            Xsoftware = (value as! [String]).map { Software(software: $0) }
            return
        }
        NSLog("---> setValue for key '\(key)' should be handled.")
    }
}

class Software {
    var __text: String = ""
    init(software: String) {
        __text = software
    }
}

class Supports: EVObject {
    var _type: YesNoEnum = .none
    var _element: String = ""
    var _attribute: String = ""
    var _value: YesNoEnum = .none
    
    override func propertyConverters() -> [(String?, ((Any?) -> ())?, (() -> Any?)?)] {
        return [( "_type", {
            self._type = (YesNoEnum(rawValue: ($0 as? String)!))!
        }, {
            return self._type
        }), ( "_value", {
            self._value = (YesNoEnum(rawValue: ($0 as? String)!))!
        }, {
            return self._value
        })]
    }
}

enum YesNoEnum: String {
    case yes = "yes"
    case no = "no"
    case none = ""
}
