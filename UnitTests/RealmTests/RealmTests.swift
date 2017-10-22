//
//  RealmTests.swift
//  UnitTests
//
//  Created by Edwin Vermeer on 29/03/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import Foundation
import RealmSwift
import XCTest
import EVReflection


// Extending only works when not using propertyConverters or propertyMapping functions
// Otherwise you would get the error: Declarations from extension cannot be overwritten yet
//extension Object: EVReflectable { }
// So for now we will add EVReflectable to every object

//: I. Define the data entities

class Person: Object, EVReflectable {
    @objc dynamic var name = ""
    @objc dynamic var age = 0
    @objc dynamic var spouse: Person?
    let cars = List<Car>()
}

class Car: Object, EVReflectable {
    @objc dynamic var brand = ""
    @objc dynamic var name: String?
    @objc dynamic var year = 0
    
    open func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [(key: "brand", decodeConverter: { value in
            self.brand = value as? String ?? ""
        }, encodeConverter: {
            return self.brand
        })]
    }
}

class PrimitiveListsObject: Object, EVReflectable {
    let strings = List<String>()
    let optionalInt = RealmOptional<Int>()
}


/**
 Testing Realm with EVReflection
 */
class RealmTests: XCTestCase {
    
    /**
     Let EVReflection know that we are using this test bundle instead of the main bundle.
     */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(Person.self)
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
        //: III. Create the objects

        let wife = Person(json: "{\"name\": \"Jennifer\", \"age\": \"47\", \"cars\": [{\"brand\": \"DeLorean\", \"name\": \"Outatime\", \"year\": 1981} , {\"brand\": \"Volkswagen\", \"year\": 2014}], \"spouse\": {\"name\": \"Marty\", \"age\": \"48\"}}")

        // set the circular reference: The spouse of my spouse is me
//Recursive objects in Realm will cause a crash!
//        wife.spouse?.spouse = wife
        
        // You will see _EVReflection_parent_ with the value 1 to indicate that there is a circular reference to it's parent 1 level up.
        print("wife = \(wife.toJsonString())")
        // Now the object printed using Realm output functionality which just repeats itself until maximum depth is exeeded
        print("wife = \(wife)")
        
        
        //: IV. Write objects to the realm
        
        try! realm.write {
            realm.add(wife)
        }
        
        
        //: V. Read objects back from the realm
        
        let favorites = ["Jennifer"]
        
        let favoritePeopleWithSpousesAndCars = realm.objects(Person.self)
            .filter("cars.@count > 1 && spouse != nil && name IN %@", favorites)
            .sorted(byKeyPath: "age")
        
        print("object = \(favoritePeopleWithSpousesAndCars.first?.toJsonString() ?? "")")
        
        for person in favoritePeopleWithSpousesAndCars {
            print(person.name)
            print(person.age)
            
            for car in person.cars {
                print("car.name = \(car.name ?? "")")
                print("car.brand = \(car.brand)")
                print("year = \(car.year)")
            }
            
            //: VI. Update objects
            guard let car = person.cars.first else {
                continue
            }

            print("old car.year = \(car.year)")
            try! realm.write {
                car.year += 3
            }
            print("new car.year = \(car.year)")
        }
        
        
        //: VII. Delete objects
        print("Number of persons in database before delete = \(realm.objects(Person.self).count)")
        
        try! realm.write {
            realm.deleteAll()
        }
        
        print("Number of persons in database after delete = \(realm.objects(Person.self).count)")
        //: Thanks! To learn more about Realm go to https://realm.io    
    }
    
    func testPrimitiveLists() {
        let obj = PrimitiveListsObject(json: "{\"strings\":[\"a\",\"b\",\"c\"]}")
        print("The object: \(obj)")
    }
}




