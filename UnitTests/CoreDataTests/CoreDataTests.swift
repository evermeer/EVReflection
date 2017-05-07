//
//  CoreDataTests.swift
//  UnitTests
//
//  Created by Vermeer, Edwin on 05/05/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import Foundation
import XCTest
import EVReflection


/**
 Testing Realm with EVReflection
 */
class CoreDataTests: XCTestCase {
    
    /**
     Let EVReflection know that we are using this test bundle instead of the main bundle.
     */
    override func setUp() {
        super.setUp()
        EVReflection.setBundleIdentifier(CoreDataPerson.self)
    }
    
    /**
     For now nothing to tearDown
     */
    override func tearDown() {
        super.tearDown()
    }
    
    /**
     Get the string name for a class and then generate a class based on that string
     */
    func testCoreDataSmokeTest() {
        let data = EVReflectionTestsData() // We use an in memory database here. So it's allwais empty.
        
        let count = data.listRecords(CoreDataPerson.self).count // should be 0
        
        // For this test also using moc (same as listRecords) because sync between boc and moc are on different threads.
        let obj = CoreDataPerson(context: data.moc, json: "{\"firstName\" : \"Edwin\", \"lastName\" : \"Vermeer\"}")
        do {
            try data.moc.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }

        // Just testing if the json parse was successfull
        let status = obj.evReflectionStatus()
        print("Json parse errors : \(status)")
        XCTAssertEqual(status, .None, "We should have a .None status")

        // Read and dump all records, assert if the count was still 0
        let list = data.listRecords(CoreDataPerson.self)
        for person in list {
            print("\(person.firstName ?? "") \(person.lastName ?? "")")
        }
        let newCount = list.count
        XCTAssert(count + 1 == newCount, "Should have one extra record")
    }
    
    

}
