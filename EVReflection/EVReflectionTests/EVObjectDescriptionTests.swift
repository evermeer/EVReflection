//
//  EVObjectDescriptionTest.swift
//
//  Created by Edwin Vermeer on 8/19/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import XCTest
@testable import EVReflection

/**
Testing EVObjectDescription
*/
class EVObjectDescriptionTests: XCTestCase {
    
    var bundle:String = ""
    
    /**
    For now nothing to setUp
    */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let a = EVObjectDescription(forObject: self)
        bundle = a.classPath[0]
        XCTAssert(bundle == "EVReflection_OSX_Tests" || bundle == "EVReflection_iOS_Tests" || bundle == "EVReflection_TVOS_Tests", "Pass")
    }
    
    /**
    For now nothing to tearDown
    */
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEVObjectDescription() {
        let a = EVObjectDescription(forObject: self)
        XCTAssert(a.classPath == [bundle, "EVObjectDescriptionTests"])
        let b = EVObjectDescription(forObject: EVObjectDescriptionTests.SubTest())
        XCTAssert(b.classPath == [bundle, "EVObjectDescriptionTests", "SubTest"], "Pass")
        let c = EVObjectDescription(forObject: EVObjectDescriptionTests.SubTest.SubSubTest())
        XCTAssert(c.classPath == [bundle, "EVObjectDescriptionTests", "SubTest", "SubSubTest"], "Pass")
        
        class FuncSubTest:NSObject {
            class FuncSubSubTest:NSObject {
                
            }
        }
        //TODO: For now these only succeed because we assume a function name will have an aditional string containing FS0_FT_T_L_ in the description. I have to reverse engineer the parameter notation for Functions.
        //Because in a bug of Xcode code coverage whe using an inline class definition, the 2 XCAsserts below will not be registered as covered
        let d = EVObjectDescription(forObject: FuncSubTest())
        XCTAssert(d.classPath == [bundle, "EVObjectDescriptionTests", "testEVObjectDescription", "FuncSubTest"], "Pass")
        let e = EVObjectDescription(forObject: FuncSubTest.FuncSubSubTest())
        XCTAssert(e.classPath == [bundle, "EVObjectDescriptionTests", "testEVObjectDescription", "FuncSubTest", "FuncSubSubTest"], "Pass")
    }

    func testIncorrectDescription() {
        let (_ , a) = testDescription("", paramb:1, paramc: "")
        XCTAssert(a.classPath == [bundle, "EVObjectDescriptionTests", "testDescription", ""], "OK... Something has changed. Or did we fixed this? Then remove this test")
    }
    
    func testDescription(param: String, paramb:Int, paramc:String) -> (a:String, b:EVObjectDescription) {
        class FuncSubTest:NSObject {
            var param: Any?
        }
        let o = FuncSubTest()
        o.param = param
        let p = EVObjectDescription(forObject: o)
        return ("", p)
    }
    
    class SubTest:NSObject {
        class SubSubTest:NSObject {
            
        }
    }
    
}









