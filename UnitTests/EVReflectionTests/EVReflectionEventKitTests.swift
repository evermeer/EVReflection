//
//  EVReflectionEventKitTests.swift
//  UnitTests
//
//  Created by Vermeer, Edwin on 28/04/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import XCTest
import Foundation
import EventKit
import EVReflection

/**
 Testing EVReflection with EKEvent
 */
class EVReflectionEventKitTests: XCTestCase {
    func testEventKit() {

        //WARNING: You will get events in your agenda! Disable next line if you want that
        return
        //XCTAssert(false)

        let exp = expectation(description: "eventStore")
        
        let store = EKEventStore()
        store.requestAccess(to: .event, completion: { (granted, error) in
            let event = EKEvent(eventStore: store)
            event.startDate = Date().addingTimeInterval(10000)
            event.title = "title"
            event.location = "here"
            event.endDate = Date().addingTimeInterval(20000)
            event.notes = "notes"
            event.calendar = store.defaultCalendarForNewEvents
            event.addAlarm(EKAlarm(absoluteDate: Date().addingTimeInterval(10000)))
            
            try? store.save(event, span: EKSpan.thisEvent, commit: true)
            
            let m = Mirror(reflecting: event)
            print("property count = \(m.children.count)")
            
            let json = event.toJsonString()
            print("json = \(json)")
            let z = EKEvent(json: json)
            print(z)
            
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error?.localizedDescription ?? "")")
        }
    }
}

extension EKObject : EVReflectable { }
