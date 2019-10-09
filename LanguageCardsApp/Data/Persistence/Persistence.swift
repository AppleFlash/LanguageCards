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
    func get<T: ManagedTransformable>(
        _ filterPredicate: TypedPredicate<T.ManagedType>
    ) -> Single<[T]>
    
    func save<T: ManagedTransformable>(_ object: T) -> Single<Void>
}
