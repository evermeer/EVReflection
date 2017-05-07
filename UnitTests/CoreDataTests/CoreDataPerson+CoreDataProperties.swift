//
//  CoreDataPerson+CoreDataProperties.swift
//  
//
//  Created by Vermeer, Edwin on 05/05/2017.
//
//

import Foundation
import CoreData


extension CoreDataPerson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataPerson> {
        return NSFetchRequest<CoreDataPerson>(entityName: "CoreDataPerson")
    }

    @NSManaged public var lastName: String?
    @NSManaged public var firstName: String?

}
