//
//  Transformable.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 05/10/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import CoreData

/**
    Это реализует managed объект
    Должна быть возможность получить plain объект из managed объекта
    ManagedObject -> PlainObject
 */
protocol PlainTransformable {
    associatedtype PlainType: ManagedTransformable where PlainType.ManagedType == Self
    
    var identifier: String { get }
    var plainObject: PlainType { get }
    static var primaryKey: String { get }
    
    func update(from plain: PlainType)
}

extension PlainTransformable {
    static var primaryKey: String { return "identifier" }
}

/**
    Это реализует plain объект
    Должна быть возможность получить идентификатор для запросов
 */
protocol ManagedTransformable {
    associatedtype ManagedType: PlainTransformable, NSManagedObject where ManagedType.PlainType == Self
    
    var identifier: String { get }
}
