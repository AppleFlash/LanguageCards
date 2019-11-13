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
    static let persistence: Persistence = CoreDataPersistence(coordinatorType: .SQLite, containerName: "LanguageCardsApp")
}

protocol Persistence: class {
    func getObjects<T: ManagedTransformable>(
        _: T.Type
    ) -> Single<[T]>
    
    func getObjects<T: ManagedTransformable>(
        using predicate: Predicate<T.ManagedType>
    ) -> Single<[T]>
    
    func getObject<T: ManagedTransformable>(
        using predicate: Predicate<T.ManagedType>
    ) -> Single<T?>
    
    func save<T: ManagedTransformable>(
        object: T
    ) -> Single<Void>
    
    func save<T: ManagedTransformable>(
        objects: [T]
    ) -> Single<Void>
    
    func deleteAll<T: ManagedTransformable>(_: T.Type) -> Single<Void>
    
    func delete<T: ManagedTransformable>(
        _: T.Type,
        predicate: Predicate<T.ManagedType>
    ) -> Single<Void>
    
    func clear() -> Single<Void>
}
