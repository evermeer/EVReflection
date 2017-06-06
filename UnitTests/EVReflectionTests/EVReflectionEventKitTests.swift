//
//  EVReflectionEventKitTests.swift
//  UnitTests
//
//  Created by Vermeer, Edwin on 28/04/2017.
//  Copyright © 2017 evict. All rights reserved.
//

#if os(tvOS)
    // Eventkit is not supported on tvOS
#else


import XCTest
import Foundation
import EventKit
import EVReflection
//import ObjectiveC.runtime
    
/**
 Testing EVReflection with EKEvent
 */

extension EKObject : EVReflectable { }

let store = EKEventStore()

class EVReflectionEventKitTests: XCTestCase {
    func testEventKit() {

//TODO: fix
// Needs a workaround. See http://stackoverflow.com/questions/43686690/mirror-of-ekevent-does-not-show-the-data
        let exp = expectation(description: "eventStore")
        
        store.requestAccess(to: .event, completion: { (granted, error) in
            let event = EKEvent(eventStore: store)
            event.startDate = Date().addingTimeInterval(10000)
            event.title = "title"
            event.location = "here"
            event.endDate = Date().addingTimeInterval(20000)
            event.notes = "notes"
            
            event.calendar = store.defaultCalendarForNewEvents
            event.addAlarm(EKAlarm(absoluteDate: Date().addingTimeInterval(10000)))
            
            //WARNING: You will get events in your agenda! Disable next line if you don't want that
            //try? store.save(event, span: EKSpan.thisEvent, commit: true)
            
            let m = Mirror(reflecting: event)
            print("mirror children = \(m.children.count)")
            
            let oc = self.properties(event)
            print(oc)
            
            for p in oc {
                var value: Any? = nil
                // Why can't we get the value like this!?
                value = event.value(forKey: p)
                print("\(p) = \(String(describing: value))")
            }
            
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
    
    func properties(_ classToInspect: NSObject) -> [String] {
        var count = UInt32()
        let classToInspect = NSURL.self
        let properties = class_copyPropertyList(classToInspect, &count)
        var propertyNames = [String]()
        let intCount = Int(count)
        for i in 0 ..< intCount {
            let property : objc_property_t = properties![i]!
            guard let propertyName = NSString(utf8String: property_getName(property)) as String? else {
                debugPrint("Couldn't unwrap property name for \(property)")
                break
            }
            propertyNames.append(propertyName)
        }
        
        free(properties)
        return propertyNames
    }
}

#endif
