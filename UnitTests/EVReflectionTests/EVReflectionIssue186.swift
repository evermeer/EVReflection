//
//  EVReflectionIssue186.swift
//  UnitTests
//
//  Created by Vermeer, Edwin on 20/04/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import Foundation
import XCTest
import EVReflection

class TestIssue186: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(BlobResourcePojo.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue186() {
        let json = "{\"flag\":true,\"message\":\"Image\",\"blobResource\":{\"id\":\"53269290-1f79-11e7-ac4a-a860b602ab0a\",\"blob_type\":\"jpeg\",\"created_by\":\"f7c6f7e2-1090-11e7-93ae-92361f002671\",\"created_on\":\"Apr 12, 2017 5:43:17 PM\",\"enable\":true,\"name\":\"f7c6f7e2-1090-11e7-93ae-92361f002671.png\",\"resource\":[80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,2,109,0,0,2,109,8,6,0,0,0,100,11,71,-66,0,0,0,1,115,82,71,66,0,-82,-50,28,-23,0,0,0,28,105,68,79,84,0,0,0,2,0,0,0,0,0,0,1,55,0,0,0,40,0,0,1,55,0,0,1,54,0,7,-107,-123,25,59,-111,-21,0,0,64,0,73,68,65,84,120,1,100,-67,-25,127,85,-25,-71,-83,-115,-23,-94,-9,-34,59,66,116,16,106,72,72,-128,68,7,81,5,-110,16,69,84,1,-94,-119,34,-44,-69,-124,122,47,-120,-34,-117,11,24,27,108,-29,94,19,39,118,122,79,-20,36,123,103,103,-97,125,-50,-5,39,-36,-17,53,-98,41,-31,-28,-100,15,-49,111,-82,-66,-26,90,107,-82,103,94,115,-116,113,-33,-77,-61,-25,-65,-8,-93,125,-11,-21,-65,-40,-41,-116,-97,-2,-26,59,-5,-39,-17,-65,-77,95,-3,-7,-17,-10,-37,-65,-4,-89,-3,-15,-81,-1,101,127,-7,-113,-1,101,127,-3,-57,-1,-74,-65,-2,23,-125,-27,-9,-1,-7,63,-10,29,-73,-3,-27,-17,-1,116,-9,121,-105,-1,-101,-21,-34,-8,-29,-9,-1,-80,63,48,-76,-4,-19,-97,-1,102,-65,-2,-35,95,-19,23,-65,-7,-34,-66,-2,-7,31,-19,-77,-97,-2,-58,62,-4,-14,23,-10,-30,-77,111,-20,-35,79,-66,-74,119,62,-2,-38,-98,127,-12,99,-106,26,95,-37,-77,15,-65]}}"
        let obj = BlobResourcePojo(json: json, forKeyPath: "blobResource")
        print("\(obj)")
    }
}



class BlobResourcePojo : EVObject{
    var id: String?
    var blob_type: String?
    var created_by: String?
    var created_on: NSDate?
    var enable: Bool = true
    var name: String?
    var resource : [NSNumber] = []
}
