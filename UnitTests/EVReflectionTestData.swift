//
//  EVReflectionTestData.swift
//  UnitTests
//
//  Created by Vermeer, Edwin on 07/05/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import Foundation
import CoreData

class EVReflectionTestsData {
    
    // MARK - Helper functions which you usually have in seperate class
    
    init() {
        let stack = try! CoreDataStack(modelName: "EVReflectionTest")
        moc = stack.mainContext
        boc = stack.backgroundContext
    }
    
    var moc: NSManagedObjectContext! // Main object context should be used for reading
    var boc: NSManagedObjectContext! // Background object context should be used for writing (from service API)
    
    func listRecords<T>(_ entityType: T.Type) -> [T] {
        let entityName = String(describing: entityType)
        let personFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let fetchedPersons = try moc.fetch(personFetch) as! [T]
            return fetchedPersons
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
        return []
    }
}
