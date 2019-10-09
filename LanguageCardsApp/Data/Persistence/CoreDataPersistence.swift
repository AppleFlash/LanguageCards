//
//  CoreDataPersistence.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 08/10/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import CoreData
import RxSwift

final class CoreDataPersistence {
    enum CoreDataError: Error {
        case wrongFetchType
    }
    
    enum CoordinatorType {
        case SQLite, inMemory
    }
    
    private let coordinatorType: CoordinatorType
    
    private let container: NSPersistentContainer
    private let queue = DispatchQueue(label: "com.queue.card.coredata")
    
    private lazy var privateWriteContext: NSManagedObjectContext = {
        let pwc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        let coordinator: NSPersistentStoreCoordinator
        switch coordinatorType {
        case .SQLite:
            coordinator = container.persistentStoreCoordinator
        case .inMemory:
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: container.managedObjectModel)
            try! coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        }
        
        pwc.persistentStoreCoordinator = coordinator
        
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
    
    init(coordinatorType: CoordinatorType) {
        self.coordinatorType = coordinatorType
        container = NSPersistentContainer(name: "LanguageCardsApp")
        container.loadPersistentStores { description, error in
            if let error = error {
                assertionFailure("Load persistence error \(error)")
            }
        }
    }
    
    private func performChanges(_ block: @escaping () -> Void) {
        backgroundContext.perform { [unowned self] in
            block()
            self.saveContext()
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
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }
    
}

extension CoreDataPersistence: Persistence {
    func get<T: ManagedTransformable>(
        _ filterPredicate: TypedPredicate<T.ManagedType>
    ) -> Single<[T]> {
        let context = backgroundContext
        
        return Single.just(filterPredicate.predicate)
            .flatMap(context.rx.getObjects)
            .flatMap { (objects: [T]) in
                if objects.isEmpty {
                    return context.rx.fetch(with: filterPredicate.predicate)
                } else {
                    return .just(objects)
                }
            }
    }
    
    func save<T: ManagedTransformable>(_ object: T) -> Single<Void> {
        return backgroundContext.rx.performInQueue()
            .flatMap { $0.rx.insert(object: object) }
            .flatMap { [unowned self] in
                return .just(self.saveContext())
            }
    }
}

private extension Reactive where Base: NSManagedObjectContext {
    func performInQueue() -> Single<Base> {
        return Single.create { [base] single in
            base.perform {
                single(.success(base))
            }
            
            return Disposables.create()
        }
    }
    
    func getObjects<T: ManagedTransformable>(for predicate: NSPredicate) -> Single<[T]> {
        return Single.create { [base] single in
            let existingObjects = base.registeredObjects
                .filter { !$0.isFault }
                .filter(predicate.evaluate)
            
            if let objects = Array(existingObjects) as? [T.ManagedType] {
                single(.success(objects.map { $0.plainObject }))
            } else {
                single(.error(CoreDataPersistence.CoreDataError.wrongFetchType))
            }
            
            return Disposables.create()
        }
    }
    
    func fetch<T: ManagedTransformable>(with predicate: NSPredicate) -> Single<[T]> {
        return Single.create { [base] single in
            let fetchRequest = NSFetchRequest<NSManagedObject>(
                entityName: String(describing: T.ManagedType.self)
            )

            fetchRequest.predicate = predicate
            fetchRequest.returnsObjectsAsFaults = false

            base.perform {
                if let results = try? base.fetch(fetchRequest) as? [T.ManagedType] {
                    single(.success(results.map { $0.plainObject }))
                } else {
                    single(.error(CoreDataPersistence.CoreDataError.wrongFetchType))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func insert<T: ManagedTransformable>(object: T) -> Single<Void> {
        return Single.create { [base] single in
            guard
                let entity = NSEntityDescription.insertNewObject(
                    forEntityName: String(describing: T.ManagedType.self),
                    into: base
                ) as? T.ManagedType
            else {
                single(.error(CoreDataPersistence.CoreDataError.wrongFetchType))
                return Disposables.create()
            }
            
            entity.update(from: object)
            single(.success(()))
            
            return Disposables.create()
        }
    }
}
