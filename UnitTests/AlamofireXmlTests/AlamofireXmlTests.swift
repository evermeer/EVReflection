//
//  AlamofireXmlToObjectsTests.swift
//  AlamofireXmlToObjectsTests
//
//  Created by Edwin Vermeer on 6/21/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import XCTest
import Alamofire
import XMLDictionary
import EVReflection

class AlamofireXmlToObjectsTests: XCTestCase {
    
        override func setUp() {
            super.setUp()
            // Put setup code here. This method is called before the invocation of each test method in the class.
            EVReflection.setBundleIdentifier(Forecast.self)
        }
        
        override func tearDown() {
            // Put teardown code here. This method is called after the invocation of each test method in the class.
            super.tearDown()
        }

    
        func testResponseObject() {
            // This is an example of a functional test case.
            let URL: URLConvertible = "http://raw.githubusercontent.com/evermeer/AlamofireXmlToObjects/master/AlamofireXmlToObjectsTests/sample_xml"
            let expectation = self.expectation(description: "\(URL)")
                        
            Alamofire.request(URL)
            .responseString { (response: DataResponse<String>) in
                print("\(response.result.value)")
            }
            .responseObjectFromXML { (response: DataResponse<WeatherResponse>) in
                expectation.fulfill()
                if let result = response.result.value {
                    print("\(result.description)")
                    XCTAssertNotNil(result.location, "Location should not be nil")
                    XCTAssertNotNil(result.three_day_forecast, "ThreeDayForcast should not be nil")
                    for forecast in result.three_day_forecast {
                        XCTAssertNotNil(forecast.day, "day should not be nil")
                        XCTAssertNotNil(forecast.conditions, "conditions should not be nil")
                        XCTAssertNotNil(forecast.temperature, "temperature should not be nil")
                    }
                    
                } else {
                    XCTAssert(false, "no result from service")
                }
            }
            
            waitForExpectations(timeout: 10) { error in
                XCTAssertNil(error, "\(error)")
            }
    }
    
    
        func testResponseObject2() {
            // This is an example of a functional test case.
            
            let URL = "http://raw.githubusercontent.com/evermeer/AlamofireXmlToObjects/master/AlamofireXmlToObjectsTests/sample_xml"
            let expectation = self.expectation(description: "\(URL)")
            
            Alamofire.request(URL)
                .responseObjectFromXML { (response: DataResponse<WeatherResponse>) in
                    
                expectation.fulfill()
                    if let result = response.result.value {
                        XCTAssertNotNil(result.location, "Location should not be nil")
                        XCTAssertNotNil(result.three_day_forecast, "ThreeDayForcast should not be nil")
                        
                        for forecast in result.three_day_forecast {
                            XCTAssertNotNil(forecast.day, "day should not be nil")
                            XCTAssertNotNil(forecast.conditions, "conditions should not be nil")
                            XCTAssertNotNil(forecast.temperature, "temperature should not be nil")
                        }
                    } else {
                        XCTAssert(false, "Could not get result from service")
                    }
            }
            
            waitForExpectations(timeout: 10) { error in
                XCTAssertNil(error, "\(error)")
            }
        }
    }

