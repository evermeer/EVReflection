//
//  EVReflectionMapping.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 11/21/15.
//  Copyright © 2015 evict. All rights reserved.
//
import XCTest
@testable import EVReflection

/**
 Testing EVReflection
 */
class EVReflectionMappingTests: XCTestCase {
    
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
    
    /**
     Get the string name for a clase and then generate a class based on that string
     */
    func testSimpleMapping() {
        let player = GamePlayer()
        player.name = "Me"
        player.memberSince = NSDate()
        player.gamesPlayed = 123
        player.rating = 76
        
        let administrator: GameAdministrator = player.mapObjectTo()
        
        // Remember that printing will use the property converter and multiply the administrator level with 4. So it will print the same as the player.
        NSLog("player = \(player)")
        NSLog("administrator = \(administrator)")

        XCTAssertEqual(administrator.name, player.name, "The names will be the same")
        XCTAssertEqual(administrator.memberSince, player.memberSince, "The member since dates will be the same")
        XCTAssertEqual(administrator.level, 19, "When creatinga an administrator it's level will be a quarter of the player rating")
        
    }
}

public class GameUser: EVObject {
    var name: String?
    var memberSince: NSDate?
}

public class GamePlayer: GameUser {
    var gamesPlayed: Int = 0
    var rating: Int = 0
}

public class GameAdministrator: GameUser {
    var usersBanned: Int = 0
    var level: Int = 0
    
    override public func propertyMapping() -> [(String?, String?)] {
        return [("level","rating")]
    }

    override public func propertyConverters() -> [(String?, (Any?)->(), () -> Any? )] {
        return [
            ( // We want a custom converter for the field isGreat
                "level"
                // isGreat will be true if the json says 'Sure'
                , { self.level = (($0 as! Int) / 4) }
                // The json will say 'Sure  if isGreat is true, otherwise it will say 'Nah'
                , { return self.level * 4})]
    }
}

