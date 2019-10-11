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
        case persistenceDoesNotExist
    }
    
    enum CoordinatorType {
        case SQLite, inMemory
        
        var type: String {
            switch self {
            case .inMemory:
                return NSInMemoryStoreType
            case .SQLite:
                return NSSQLiteStoreType
            }
        }
    }
    
    private let coordinatorType: CoordinatorType
    
    private let container: NSPersistentContainer
    private let queue = DispatchQueue(label: "com.queue.card.coredata")
    private var storeCoordinator: NSPersistentStoreCoordinator!
    
    private lazy var privateWriteContext: NSManagedObjectContext = {
        let pwc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        let coordinator: NSPersistentStoreCoordinator
        switch coordinatorType {
        case .SQLite:
            coordinator = container.persistentStoreCoordinator
        case .inMemory:
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: container.managedObjectModel)
            try! coordinator.addPersistentStore(ofType: coordinatorType.type, configurationName: nil, at: nil, options: nil)
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
    
    fileprivate static func identityPredicate<T: ManagedTransformable>(identifier: CVarArg) -> TypedPredicate<T> {
        return .init(predicate: .init(format: "%K == %@", T.ManagedType.primaryKey, identifier))
    }
    
    init(coordinatorType: CoordinatorType) {
        self.coordinatorType = coordinatorType
        container = NSPersistentContainer(name: "LanguageCardsApp")
        container.loadPersistentStores { [unowned self] description, error in
            if let error = error {
                assertionFailure("Load persistence error \(error)")
            } else {
                self.storeCoordinator = self.privateWriteContext.persistentStoreCoordinator
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
    
    private func getManagedObjects<T: ManagedTransformable>(
        _: T.Type,
        _ predicate: Predicate<T.ManagedType>?
    ) -> Single<[T.ManagedType]> {
        return backgroundContext.rx.performInQueue()
            .flatMap { $0.rx.getOrFetch(T.self, with: predicate) }
    }
    
    private func delete(entityName: String, predicate: NSPredicate? = nil) throws -> [NSManagedObjectID] {
        let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        deleteRequest.predicate = predicate
        
        if storeCoordinator.persistentStores.first!.type == CoordinatorType.inMemory.type {
            try backgroundContext.execute(deleteRequest)
            
            return []
        } else {
            let batchRequest = NSBatchDeleteRequest(fetchRequest: deleteRequest)
            batchRequest.resultType = .resultTypeObjectIDs
            
            let execResult = try storeCoordinator.execute(
                batchRequest,
                with: backgroundContext
            ) as! NSBatchDeleteResult
            
            return execResult.result as! [NSManagedObjectID]
        }
    }
    
    private func mergeDeletedObjects(_ ids: [NSManagedObjectID]) {
        guard !ids.isEmpty else {
            return
        }
        
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: [NSDeletedObjectsKey: ids],
            into: [backgroundContext]
        )
    }
}

extension CoreDataPersistence: Persistence {
    func getAll<T: ManagedTransformable>(
        _: T.Type
    ) -> Single<[T]> {
        return getManagedObjects(T.self, nil)
            .map { $0.map { $0.plainObject } }
    }
    
    func get<T: ManagedTransformable>(
        _ predicate: Predicate<T.ManagedType>
    ) -> Single<[T]> {
        return getManagedObjects(T.self, predicate)
            .map { $0.map { $0.plainObject } }
    }
    
    func getObject<T: ManagedTransformable>(
        with predicate: Predicate<T.ManagedType>
    ) -> Single<T?> {
        return getManagedObjects(T.self, predicate)
            .map { $0.first }
            .map { $0?.plainObject }
    }
    
    func save<T: ManagedTransformable>(
        object: T
    ) -> Single<Void> {
        return backgroundContext.rx.performInQueue()
            .flatMap { $0.rx.update(object: object) }
            .flatMap { [unowned self] in
                return .just(self.saveContext())
            }
    }
    
    func save<T: ManagedTransformable>(
        objects: [T]
    ) -> Single<Void> {
        return backgroundContext.rx.performInQueue()
            .flatMap { $0.rx.update(objects: objects) }
            .flatMap { [unowned self] in
                return .just(self.saveContext())
            }
    }
    
    func deleteAll<T: ManagedTransformable>(_: T.Type) -> Single<Void> {
        return backgroundContext.rx.performInQueue()
            .flatMap { [weak self] context -> Single<[NSManagedObjectID]> in
                guard let self = self else {
                    return .error(CoreDataError.persistenceDoesNotExist)
                }
                
                let ids = try self.delete(entityName: String(describing: T.ManagedType.self))
                return .just(ids)
            }
            .flatMap { [unowned self] in
                self.mergeDeletedObjects($0)
                return .just(self.saveContext())
            }
    }
    
    func delete<T: ManagedTransformable>(
        _: T.Type,
        predicate: Predicate<T.ManagedType>
    ) -> Single<Void> {
        return backgroundContext.rx.performInQueue()
            .flatMap { [weak self] context -> Single<[NSManagedObjectID]> in
                guard let self = self else {
                    return .error(CoreDataError.persistenceDoesNotExist)
                }
                
                let ids = try self.delete(
                    entityName: String(describing: T.ManagedType.self),
                    predicate: predicate.toSystemPredicate
                )
                return .just(ids)
            }
            .flatMap { [unowned self] in
                self.mergeDeletedObjects($0)
                return .just(self.saveContext())
            }
    }
    
    func clear() -> Single<Void> {
        return backgroundContext.rx.performInQueue()
            .flatMap { [weak self] context -> Single<[NSManagedObjectID]> in
                guard let self = self else {
                    return .error(CoreDataError.persistenceDoesNotExist)
                }

                let names = self.storeCoordinator.managedObjectModel.entities.compactMap { $0.name }
                let ids = try names.flatMap { try self.delete(entityName: $0) }

                return .just(ids)
            }
            .flatMap { [unowned self] in
                self.mergeDeletedObjects($0)
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
    
    func getOrFetch<T: ManagedTransformable>(_: T.Type, with predicate: Predicate<T.ManagedType>?) -> Single<[T.ManagedType]> {
        return getObjects(T.self, for: predicate?.toSystemPredicate)
            .flatMap { objects in
                if objects.isEmpty {
                    return self.fetch(T.self, with: predicate)
                } else {
                    return Single.just(objects)
                }
            }
    }
    
    func getObjects<T: ManagedTransformable>(_: T.Type, for predicate: NSPredicate?) -> Single<[T.ManagedType]> {
        return Single.create { [base] single in
            guard let predicate = predicate else {
                single(.success([]))
                return Disposables.create()
            }
            
            let existingObjects = base.registeredObjects
                .filter { !$0.isFault }
                .filter(predicate.evaluate)
            
            if let objects = Array(existingObjects) as? [T.ManagedType] {
                single(.success(objects))
            } else {
                single(.error(CoreDataPersistence.CoreDataError.wrongFetchType))
            }
            
            return Disposables.create()
        }
    }
    
    func fetch<T: ManagedTransformable>(_: T.Type, with predicate: Predicate<T.ManagedType>?) -> Single<[T.ManagedType]> {
        return Single.create { [base] single in
            let fetchRequest = NSFetchRequest<T.ManagedType>(
                entityName: String(describing: T.ManagedType.self)
            )
            predicate.map { CoreDataRequest.apply($0, to: fetchRequest) }
            
            fetchRequest.returnsObjectsAsFaults = false

            base.perform {
                if let results = try? base.fetch(fetchRequest) {
                    single(.success(results))
                } else {
                    single(.error(CoreDataPersistence.CoreDataError.wrongFetchType))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func update<T: ManagedTransformable>(
        object: T
    ) -> Single<Void> {
        return update(objects: [object])
    }
    
    func update<T: ManagedTransformable>(
        objects: [T]
    ) -> Single<Void> {
        let predicate = NSPredicate(format: "%K IN %@", T.ManagedType.primaryKey, objects.map { $0.identifier })
        
        return getOrFetch(T.self, with: .from(predicate: predicate))
            .flatMap { [base] existingObjects in
                for plain in objects {
                    let entity = existingObjects.first { $0.identifier == plain.identifier } ?? T.ManagedType(context: base)
                    entity.update(from: plain)
                }
                
                return .just(())
            }
    }
}
