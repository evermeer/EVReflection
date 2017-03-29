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
@testable import EVReflection


//: 0. Extend Realm List with EVCustomReflectable to enable custom parsing

extension List : EVCustomReflectable { }


//: I. Define the data entities

class Person: Object, EVReflectable {
    dynamic var name = ""
    dynamic var age = 0
    dynamic var spouse: Person?
    var cars = List<Car>()
    
    override var description: String { return "Person {\(name), \(age), \(spouse?.name ?? "")}" }
    
    
    func propertyConverters() -> [(key: String, decodeConverter: ((Any?)->()), encodeConverter: (() -> Any?))] {
        return [
            ( // We want a custom converter for the field isGreat
                key: "cars",
                // We do the list parsing ourselves.
                decodeConverter: {
                    for dict in ($0 as? NSArray) ?? NSArray() {
                        if let dict = dict as? NSDictionary {
                            self.cars.append(Car(dictionary: dict))
                        }
                    }
                },
                // The json will say 'Sure  if isGreat is true, otherwise it will say 'Nah'
                encodeConverter: {
                    return self.cars.map { $0.toDictionary() }
            })]
    }    
}

class Car: Object, EVReflectable {
    dynamic var brand = ""
    dynamic var name: String?
    dynamic var year = 0
    
    override var description: String { return "Car {\(brand), \(name ?? ""), \(year)}" }
}



/**
 Testing EVReflection
 */
class RealmTests: XCTestCase {
    
    /**
     For now nothing to setUp
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
        
        let wife = Person(json: "{\"name\": \"Jennifer\", \"age\": \"47\", \"cars\": [{\"brand\": \"DeLorean\", \"name\": \"Outatime\", \"year\": 1981} , {\"brand\": \"Volkswagen\", \"year\": 2014}]}")
        
        let husband = Person(value: [
            "name": "Marty",
            "age": 48,
            "spouse": wife
            ])
        
        wife.spouse = husband

        // You will see _EVReflection_parent_ with the value 1 to indicate that there is a circular reference to it's parent 1 level up.
        print("wife = \(wife.toJsonString())")
        
        
        //: IV. Write objects to the realm
        
        try! realm.write {
            realm.add(husband)
        }
        
        //: V. Read objects back from the realm
        
        let favorites = ["Jennifer"]
        
        let favoritePeopleWithSpousesAndCars = realm.objects(Person.self)
            .filter("cars.@count > 1 && spouse != nil && name IN %@", favorites)
            .sorted(byKeyPath: "age")
        
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
}





