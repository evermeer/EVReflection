//
//  XmlTestObjects.swift
//  EVReflection
//
//  Created by Scott Riccardelli on 5/19/16.
//  Copyright © 2016 evict. All rights reserved.
//

import Foundation
import CoreGraphics
import XCTest
@testable import EVReflection


class Measure: EVObject {
    var __name: String = ""
    var _number: Int64 = 0
    var _width: Int64 = 0
    // var note: [Note]? = []
    var direction: [Direction]? = []
}

class Direction: EVObject {
    var __name: String = ""
    var _placement: String = ""
    var _directive: String = ""
    
    var directionType: [DirectionType]? = []
}

class DirectionType: EVObject {
    var words: [Words]? = []
}

class Words: EVObject {
    var __text: String = ""
    var _defaultY: Int = 0
    var _fontSize: Int = 0
    var _fontWeight: String = ""
    var _xmlLang: String = ""
}

class TestIssue84: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(Measure.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let dictionary = [
            "__name": "measure",
            "_number": 1,
            "_width": 324,
            "direction": [
                [
                    "_directive": "yes",
                    "_placement": "above",
                    "directionType": [
                        "words": [
                                 "__text": "Ziemlich und mit Ausdruck",
                                 "_defaultY": 26,
                                 "_fontSize": 11,
                                 "_fontWeight": "bold"
                        ],
                    ]
                ],
                [
                    "_directive": "yes",
                    "_placement": "above",
                ]
            ],
            ] as [String : Any]
        
        print(dictionary)
        
        let obj = Measure(dictionary: dictionary as NSDictionary)
        
        print(EVReflection.description(obj))
        
    }
}





