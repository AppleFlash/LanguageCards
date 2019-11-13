//
//  TestParent.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 11.11.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import CoreData

@objc(TestParentEntity)
public class TestParentEntity: NSManagedObject, PlainTransformable {
    public typealias PlainType = PlainTestParent
    
    @NSManaged public var identifier: String
    @NSManaged public var name: String
    @NSManaged public var changeableField: String
    @NSManaged public var childs: Set<TestChildEntity>?
    
    public var plainObject: PlainType {
        return .init(
            identifier: identifier,
            name: name,
            changeableField: changeableField,
            childs: childs?.map { $0.plainObject }
        )
    }
    
    public func update(from plain: PlainType) {
        guard let context = managedObjectContext else {
            fatalError()
        }
        
        self.identifier = plain.identifier
        self.name = plain.name
        self.changeableField = plain.changeableField
//        let predicate = Predicate().filter(\TestChildEntity.identifier == plain.child.identifier).batch(0..<1)
//
//        child = context.getOrCreateObject(
//            predicate,
//            using: plain.child
//        )
        if let childs = plain.childs {
            let predicate = Predicate().filter(
                .key(
                    \TestChildEntity.identifier,
                    in: childs.map { $0.identifier }
                )
            )
            
            self.childs = context.getOrCreateCollection(
                predicate,
                using: childs
            )
        }
    }
}

public struct PlainTestParent: TestCoreDataPlainObject, Equatable {
    public typealias ManagedType = TestParentEntity
    
    public var identifier: String
    public let name: String
    public var changeableField: String
    public var childs: [PlainTestChild]?
    
    static func new() -> PlainTestParent {
        return .init(
            identifier: UUID().uuidString,
            name: .random(),
            changeableField: .random(),
            childs: [.new()]//, .new(), .new()]
        )
    }
    
    static func identicalPredicate(with object: PlainTestParent) -> TypedPredicate<ManagedType> {
        return \ManagedType.identifier == object.identifier
    }
}
