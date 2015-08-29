//
//  EVObjectDescriptionTest.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 8/19/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import UIKit
import XCTest

/**
Testing EVObjectDescription
*/
class EVObjectDescriptionTests: XCTestCase {
    
    /**
    For now nothing to setUp
    */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    /**
    For now nothing to tearDown
    */
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEVObjectDescription() {
        //TODO: Add XCTAssert tests
        let a = EVObjectDescription(forObject: self)
        let b = EVObjectDescription(forObject: EVObjectDescriptionTests.SubTest())
        let c = EVObjectDescription(forObject: EVObjectDescriptionTests.SubTest.SubSubTest())
        
        class FuncSubTest:NSObject {
            class FuncSubSubTest:NSObject {
                
            }
        }
        //TODO: For now these only succeed because we assume a function name will have an aditional string containing FS0_FT_T_L_ in the description. I have to reverse engineer the parameter notation for Functions.
        let d = EVObjectDescription(forObject: FuncSubTest())
        let e = EVObjectDescription(forObject: FuncSubTest.FuncSubSubTest())
        
    }

    class SubTest:NSObject {
        class SubSubTest:NSObject {
            
        }
    }

}
