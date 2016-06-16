//
//  EVReflectionIssue96.swift
//  EVReflection
//
//  Created by Oliver Ziegler on 16/06/16.
//  Copyright © 2016 evict. All rights reserved.
//

import Foundation
import XCTest
@testable import EVReflection


class News: NSObject {
    var id: Int = 0
    var title: String = ""
    var text: String = ""
    var date: NSDate = NSDate()
}

class PayloadClass: EVObject {
}

class PayloadNews: PayloadClass {
    var news: [News] = []
}

class PayloadNumbers: PayloadClass {
    var numbers: [Int] = []
}



class TestIssue96: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(Encoding)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue96() {
        let numbersJson = "{\"numbers\": [1,2,3,4]}"
        let numbersObj = PayloadNumbers(json: numbersJson)
        print(numbersObj)
        
        let news1 = "{\"id\":13,\"title\":\"Some title\",\"text\":\"<p>Some HTML Text<\\/p>\",\"date\":\"2016-06-15T16:47:04+0200\"}"
        let news2 = "{\"id\":24,\"title\":\"Some other title\",\"text\":\"<p>Some other HTML Text<\\/p>\",\"date\":\"2016-06-15T19:47:04+0200\"}"
        
        //let newsObject1 = News(json: news1)
        //print(newsObject1)
        
        //let newsObject2 = News(json: news2)
        //print(newsObject2)
        
        let news = "[\(news1),\(news2)]"
        let newsArray = [News](json: news)
        print(newsArray)
        
        let payload = "{\"news\":\(news)}"
        let payloadObj = PayloadNews(json: payload)
        print(payloadObj)
    }
    
}
