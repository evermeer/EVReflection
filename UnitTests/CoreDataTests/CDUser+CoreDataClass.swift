//
//  CDUser+CoreDataClass.swift
//  UnitTests
//
//  Created by Vermeer, Edwin on 30/05/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import Foundation
import CoreData
import EVReflection

@objc(CDUser)
public class CDUser: BaseEntity {
    @NSManaged var userProperty: String
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUser> {
        return NSFetchRequest<CDUser>(entityName: "CDUser")
    }
}

public class BaseEntity: EVManagedObject {
    @NSManaged var id: String
    
    /* This works
    override public func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "_id", let value = value as? String {
            id = value
        }
    }
    */
    
    // This will give a warning that _id cannot be found. Mirror for a NSManagedObject will not return the keys for fields that are not set yet.
    override public func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [
            ("id", "_id")
        ]
    }
}

