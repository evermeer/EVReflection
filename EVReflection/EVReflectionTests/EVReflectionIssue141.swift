//
//  EVReflectionIssue141.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 17/11/2016.
//  Copyright © 2016 evict. All rights reserved.
//

import Foundation
import XCTest
@testable import EVReflection

class EVReflectionIssue141: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(MoreSection.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIssue141() {
        let dic = NSMutableDictionary()
        dic["name"] = "wow";
        
        let mainDic = NSMutableDictionary()
        mainDic["items"] = [dic];
        
        let item: ClassA = ClassA(dictionary: mainDic)
        
        print("item = \(item)")
    }
}

public class ClassB: EVObject {
    public var name: String?
}

public class ClassA: EVObject {
    public var items:Array<ClassB> = []
}
