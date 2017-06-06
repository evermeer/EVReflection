//
//  CoreDataStack.swift
//  UnitTests
//
//  Created by Vermeer, Edwin on 06/05/2017.
//  Copyright © 2017 evict. All rights reserved.
//

import Foundation
import CoreData
import EVReflection

class CoreDataStack {
    let mainContext: NSManagedObjectContext // Use this for reading data
    let backgroundContext: NSManagedObjectContext // Use this for writing data

    private let coordinater: NSPersistentStoreCoordinator
    private var mainContesxtSaveObserver: NSObjectProtocol?
    private var backgroundContesxtSaveObserver: NSObjectProtocol?
    
    init(modelName: String) throws {
        // This resource is the same name as your xcdatamodeld contained in your project.
        let bundle = Bundle.init(for: CoreDataStack.self)
        
        guard let modelURL = bundle.url(forResource: modelName, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        coordinater = NSPersistentStoreCoordinator(managedObjectModel: model)
        let _ = try? coordinater.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)

        mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.persistentStoreCoordinator = coordinater
        mainContext.name = "Main Context"
        mainContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.persistentStoreCoordinator = coordinater
        backgroundContext.name = "Background Context"
        backgroundContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        
        let center = NotificationCenter.default
        mainContesxtSaveObserver = center.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: mainContext, queue: nil) { (note) in
            self.backgroundContext.perform {
                self.backgroundContext.mergeChanges(fromContextDidSave: note)
            }
        }
        backgroundContesxtSaveObserver = center.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: backgroundContext, queue: nil) { (note) in
            self.mainContext.perform {
                self.mainContext.mergeChanges(fromContextDidSave: note)
            }
        }
    }
    
    deinit {
        if let observer = mainContesxtSaveObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = backgroundContesxtSaveObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
