//
//  EVReflectionPerformance.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 4/7/16.
//  Copyright © 2016 evict. All rights reserved.
//


import XCTest
@testable import EVReflection

/**
 Testing EVReflection
 */
class EVReflectionPerformance: XCTestCase {
    
    
    /**
     For now nothing to setUp
     */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(TestObject)
    }
    
    /**
     For now nothing to tearDown
     */
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testManyObjects() {
        let startTime = NSDate()
        let start = report_memory()
        dotest()
        let midle = report_memory()
        let midleTime = NSDate()
        dotest()
        let end = report_memory()
        let endTime = NSDate()
        
        print("\n\nstart = \(start)\nincrease = \(midle - start)\nmidle = \(midle)\nincrease = \(end - midle)\nend = \(end)")
        print("startTime = \(startTime)\nincrease = \(midleTime.timeIntervalSinceDate(startTime))\nmidle = \(midleTime)\nincrease = \(endTime.timeIntervalSinceDate(midleTime))\nend = \(endTime)\n\n")
        
    }
    
    func dotest() {
        let a = TestObject4()
        for _ in 1...1000 {
            a.array4.append(TestObject2())
        }
        let b = a.toJsonString()
        let c = TestObject4(json: b)
        XCTAssertEqual(c.array4.count, 1000, "Should still have 10000 objects in the list")
    }
    
    func report_memory() -> UInt {
        var info = task_basic_info()
        var count = mach_msg_type_number_t(sizeofValue(info))/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(&info) {
            
            task_info(mach_task_self_,
                      task_flavor_t(TASK_BASIC_INFO),
                      task_info_t($0),
                      &count)
            
        }
        
        if kerr == KERN_SUCCESS {
            print("Memory in use (in bytes): \(info.resident_size)")
            return info.resident_size
        }
        else {
            print("Error with task_info(): " +
                (String.fromCString(mach_error_string(kerr)) ?? "unknown error"))
            return 0
        }
    }
}