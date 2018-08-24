//
//  EVReflectionEVCustomReflectable.swift
//  UnitTests
//
//  Created by Vermeer, Edwin on 16/05/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import Foundation
import EVReflection
import XCTest


class EVReflectionEVCustomReflectable: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(XObject.self)
    }
    
    func test() {
        let jsonOriginal = "{\"id\":24,\"tst\":\"Encode this\",\"name\":\"Bob Jefferson\"}"
        let p = XObject(json: jsonOriginal)
        print(p.description)
        let jsonNew = p.toJsonString()
        print(jsonNew)
        XCTAssertEqual(jsonOriginal, jsonNew, "Generated json should be the same as the original")
    }

}


open class XObject: EVObject {
    var id: NSNumber = 0
    var tst: String?
    
     // Contains all the attributes that do not have a defined key for an attribute
    fileprivate var attributes: NSMutableDictionary = NSMutableDictionary()
    open override func setValue(_ value: Any!, forUndefinedKey key: String) {
        attributes[key] = value
    }
}

extension XObject : EVCustomReflectable {
    public static func constructWith(value: Any?) -> EVCustomReflectable? {
        return XObject().constructWith(value: value)
    }
    public func constructWith(value: Any?) -> EVCustomReflectable? {
        if let jsonDict = value as? NSDictionary {
            EVReflection.setPropertiesfromDictionary(jsonDict, anyObject: self)
        }
        return self
    }
    public func toCodableValue() -> Any {
        let d: NSMutableDictionary = self.toDictionary() as? NSMutableDictionary ?? NSMutableDictionary()
        let a: NSDictionary = d["attributes"] as? NSDictionary ?? NSDictionary()
        d.removeObject(forKey: "attributes")
        d.unionInPlace(dictionary: a)
        return d
    }
}

 
