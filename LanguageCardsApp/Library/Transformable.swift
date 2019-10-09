//
//  Transformable.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 05/10/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

protocol EmptyInitializable {
    init()
}

typealias ManagedInitializableType = EmptyInitializable & PlainTransformable

/**
    Это реализует managed объект
    Должна быть возможность получить plain объект из managed объекта
    ManagedObject -> PlainObject
 */
protocol PlainTransformable {
    associatedtype PlainType: ManagedTransformable where PlainType.ManagedType == Self
    associatedtype IdentifierType
    
    var identifier: IdentifierType { get }
    var plainObject: PlainType { get }
    
    func update(from plain: PlainType)
}

/**
    Это реализует plain объект
    Должна быть возможность получить идентификатор для запросов
 */
protocol ManagedTransformable {
    associatedtype ManagedType: ManagedInitializableType where ManagedType.PlainType == Self
    associatedtype IdentifierType
    
    var identifier: IdentifierType { get }
}

//class RealmObject: PlainTransformable, EmptyInitializable {
//    var id: String = ""
//    var name: String = ""
//
//    var plainObject: PlainObject {
//        return .init(identifier: id, name: name)
//    }
//
//    required init() {
//        id = ""
//        name = ""
//    }
//
//    func update(from plain: PlainObject) {
//        self.id = plain.identifier
//        self.name = plain.name
//    }
//}

//class CoreDataObject: PlainTransformable & EmptyInitializable {
//    var id: String = ""
//    var name: String = ""
//
//    var plainObject: PlainObject {
//        return .init(identifier: id, name: name)
//    }
//
//    required init() {
//        fatalError()
//    }
//
//    func update(from plain: PlainObject) {
//        self.id = plain.identifier
//        self.name = plain.name
//    }
//}
//
//struct PlainObject: ManagedTransformable {
//    typealias ManagedType = CoreDataObject
//
//    var identifier: String = ""
//    var name: String = ""
//}
//
/////
//
//protocol DataBaseGateway {
//    func save<T: ManagedTransformable>(_ object: T)
//}
//
//class RealmPersistence: DataBaseGateway {
//    func save<T: ManagedTransformable>(_ object: T) {
//        let managedObject = T.ManagedType()
//        managedObject.update(from: object)
//    }
//}
//
//class CoreDataPersistence: DataBaseGateway {
//    func save<T: ManagedTransformable>(_ object: T) {
//
//    }
//}
