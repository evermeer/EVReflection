//
//  AlamofireXmlToObjects3Tests.swift
//  AlamofireXmlToObjects
//
//  Created by Edwin Vermeer on 6/5/16.
//  Copyright © 2016 evict. All rights reserved.
//

import XCTest
import Alamofire
import Xml2Dictionary
import EVReflection

class AllGames: EVObject {
    var __name: String?
    var StateProv: StateProvObject?
}

class StateProvObject: EVObject {
    var __name: String?
    var _stateprov_name: String?
    var _stateprov_id: String?
    var game: [Game] = []
}

class Game: EVObject {
    var __name: String?
    var _game_id: Int = 0
    var _game_name: String?
    var _update_time: Date?
    var lastdraw_date: String?
    var lastdraw_numbers: String?
    var nextdraw_date: String?
    var jackpot: Jackpot?
}

class Jackpot: EVObject {
    var __text: String?
    var _date: String?
}

class AlamofireXmlToObjects3Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(AllGames.self)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testResponseObject() {
        // This is an example of a functional test case.
        let URL: URLConvertible = "http://raw.githubusercontent.com/evermeer/AlamofireXmlToObjects/master/AlamofireXmlToObjectsTests/sample3_xml"
        let expectation = self.expectation(description: "\(URL)")

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "ddd yyyy'-'MM'-'dd' 'HH':'mm':'ss Z"
        EVReflection.setDateFormatter(dateFormatter)

        Alamofire.request(URL)
            .responseObjectFromXML { (response: DataResponse<AllGames>) in
                expectation.fulfill()
                if let error = response.result.error {
                    XCTAssert(false, "ERROR: \(error.localizedDescription)")
                } else {
                    if let result = response.result.value {
                        print("\(result.description)")
                    } else {
                        XCTAssert(false, "no result from service")
                    }
                }
        }

        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error)")
        }
    }

}
