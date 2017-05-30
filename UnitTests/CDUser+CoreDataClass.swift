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
}

