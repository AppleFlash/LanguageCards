//
//  CoreDataPersistence.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 08/10/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import CoreData

final class CoreDataPersistence {
    static let shared: CoreDataPersistence = .init()
    
    private let container: NSPersistentContainer
    private let queue = DispatchQueue(label: "com.queue.card.coredata")
    
    private lazy var privateWriteContext: NSManagedObjectContext = {
        let pwc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        pwc.persistentStoreCoordinator = container.persistentStoreCoordinator
        container.viewContext.persistentStoreCoordinator = nil
        
        return pwc
    }()
    
    private(set) lazy var mainContext: NSManagedObjectContext = {
        let mwc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mwc.parent = privateWriteContext
        
        return mwc
    }()
    
    private lazy var backgroundContext: NSManagedObjectContext = {
        let bgc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bgc.parent = mainContext
        
        return bgc
    }()
    
    private init() {
        container = NSPersistentContainer(name: "LanguageCardsApp")
        container.loadPersistentStores { description, error in
            if let error = error {
                assertionFailure("Load persistence error \(error)")
            }
        }
    }
    
    private func saveContext() {
        trySave(context: backgroundContext)
        trySave(context: mainContext)
        trySave(context: privateWriteContext)
    }
    
    private func trySave(context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        context.performAndWait {
            try! context.save()
        }
    }
}

extension CoreDataPersistence: Persistence {
    func get<T: ManagedTransformable>(
        _ filterPredicate: TypedPredicate<T.ManagedType>
    ) -> [T] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(
            entityName: String(describing: T.ManagedType.self)
        )
        guard fetchRequest.resultType is T.ManagedType else {
            fatalError()
        }
        
        fetchRequest.predicate = filterPredicate.predicate
        fetchRequest.returnsObjectsAsFaults = false
        var res: [T] = []
        backgroundContext.performAndWait {
            res = (try! backgroundContext.fetch(fetchRequest) as! [T.ManagedType]).map { $0.plainObject }
        }
        
        return res
    }
    
    func save<T: ManagedTransformable>(_ object: T) {
        guard
            let entityDescription = NSEntityDescription.entity(
                forEntityName: String(describing: T.ManagedType.self),
                in: backgroundContext
            ),
            let entity = NSManagedObject(
                entity: entityDescription,
                insertInto: backgroundContext
            ) as? T.ManagedType
        else {
            fatalError()
        }
        
        entity.update(from: object)
        saveContext()
    }
}
