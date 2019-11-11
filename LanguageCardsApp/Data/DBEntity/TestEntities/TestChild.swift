//
//  TestChild.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 11.11.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import CoreData

@objc(TestChildEntity)
public class TestChildEntity: NSManagedObject, PlainTransformable {
    public typealias PlainType = PlainTestChild
    
    @NSManaged public var identifier: String
    @NSManaged public var age: Int
    @NSManaged public var changeableField: String
    
    public var plainObject: PlainType {
        return .init(
            identifier: identifier,
            age: age,
            changeableField: changeableField
        )
    }
    
    public func update(from plain: PlainType) {
        self.identifier = plain.identifier
        self.age = plain.age
        self.changeableField = plain.changeableField
    }
}

public struct PlainTestChild: TestCoreDataPlainObject, Equatable {
    public typealias ManagedType = TestChildEntity
    
    public var identifier: String
    public let age: Int
    public var changeableField: String
    
    static func new() -> PlainTestChild {
        return .init(identifier: UUID().uuidString, age: .random(in: 10...100), changeableField: .random())
    }
    
    static func identicalPredicate(with object: PlainTestChild) -> TypedPredicate<ManagedType> {
        return \ManagedType.identifier == object.identifier
    }
}
