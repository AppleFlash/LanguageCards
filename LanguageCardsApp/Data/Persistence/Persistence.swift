//
//  Persistence.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 08/10/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import CoreData
import RxSwift

final class PersistenceFactory {
    static let persistence: Persistence = CoreDataPersistence(coordinatorType: .SQLite)
}

protocol Persistence: class {
    func getAll<T: ManagedTransformable>(
        _: T.Type
    ) -> Single<[T]>
    
    func get<T: ManagedTransformable>(
        _ filterPredicate: TypedPredicate<T.ManagedType>
    ) -> Single<[T]>
    
    func getObject<T: ManagedTransformable>(
        with filterPredicate: TypedPredicate<T.ManagedType>
    ) -> Single<T?>
    
    func save<T: ManagedTransformable>(
        object: T
    ) -> Single<Void>
    
    func save<T: ManagedTransformable>(
        objects: [T]
    ) -> Single<Void>
    
    func deleteAll<T: ManagedTransformable>(_: T.Type) -> Single<Void>
    
    func delete<T: ManagedTransformable>(_: T.Type, predicate: TypedPredicate<T.ManagedType>) -> Single<Void>
    
    func clear() -> Single<Void>
}
