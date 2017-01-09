//
//  ArrayDeserializationPerformanceTest.swift
//  EVReflection
//
//  Created by raf on 4/30/16.
//  Copyright © 2016 evict. All rights reserved.
//

import Foundation
import EVReflection

class User: EVObject {
    var theId: Int = 0
    var name: String = ""
    var email: String?
    var company: Company?
    var closeFriends: [User]? = []
    var birthDate: NSDate?
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        
    }
}

class Company: EVObject {
    var name: String = ""
    var address: String?
}

class ArrayDeserializationPerformanceTest: NSObject {
    
    func performanceTest1() {
        
        var json = "[\n"
        for idx in 0...1000 {
            json += "{\n"
                + "\"the_id\": \(idx),\n"
                + "\"name\" : \"John Appleseed Clone #\(idx)\",\n"
                + "\"email\" : \"john_\(idx)@appleseed.com\",\n"
                + "\"company\" : {\n"
                + "    \"name\" : \"Apple\",\n"
                + "    \"address\": \"1 Infinite Loop, Cupertino, CA\"\n"
                + "},\n"
                + "\"close_friends\" : [\n"
                +     "{ \"the_id\" : \(idx+1), \"name\" : \"Bob Jefferson #\(idx+1)\" },\n"
                +     "{ \"theId\" : \(idx+2), \"name\" : \"Jen Jackson #\(idx+2)\" }\n"
                + "]\n"
                + "},\n\n"
        }
        json += "]"
        
        let startTime = NSDate()
        
        //print("\(json)")
        let deserialized = [User](json: json)
        
        let endTime = NSDate()
        
        let elapsedTime = endTime.timeIntervalSince(startTime as Date)
        print("deserialized count = \(deserialized.count)")
        print (String(format:"Operation took %.2fs", elapsedTime))
        
    }
}
