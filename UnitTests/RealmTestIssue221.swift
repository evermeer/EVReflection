//
//  RealmTestIssue221.swift
//  UnitTests
//
//  Created by Vermeer, Edwin on 30/07/2017.
//  Copyright © 2017 evict. All rights reserved.
//


import Foundation
import RealmSwift
import XCTest
import EVReflection


//: I. Define the data entities

class CategoryModel: Object, EVReflectable{
    
    dynamic var children = ""
    dynamic var id = ""
    dynamic var isRoot =  false
    let name =  List<NameCategoryModel>()
}

class NameCategoryModel: Object, EVReflectable{
    dynamic var locale = ""
    dynamic var value = ""
}


/**
 Testing Realm with EVReflection
 */
class RealmTestsIssue221: XCTestCase {
    
    /**
     Let EVReflection know that we are using this test bundle instead of the main bundle.
     */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(CategoryModel.self)
    }
    
    /**
     For now nothing to tearDown
     */
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //: II. Init the realm file
    let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "TemporaryRealm"))
    
    /**
     Get the string name for a class and then generate a class based on that string
     */
    func testRealmSmokeTest() {
        let path: String = Bundle(for: type(of: self)).path(forResource: "RealmTestIssue221", ofType: "json") ?? ""
        let content = try! String(contentsOfFile: path)
        let data = [CategoryModel](json: content)
        print("\(data)")
    }
}





