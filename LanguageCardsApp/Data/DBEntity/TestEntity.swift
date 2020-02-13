//
//  TestEntity.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 04/11/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import CoreData

extension String {
    static func random(length: Int = 10) -> String {
        let characterSet = "qwertyuiop[]\';lkjhgfdsazxcvbnm,./QWERTYUIOPLKJHGFDSAZXCVBNM1234567890-="
        var newString = ""
        for _ in 0..<10 {
            newString += String(characterSet.randomElement() ?? Character(""))
        }
        
        return newString
    }
}

@objc(TestEntity)
public class TestEntity: NSManagedObject, PlainTransformable {
    public typealias PlainType = PlainTestEntity
    
    @NSManaged public var identifier: String
    @NSManaged public var name: String
    @NSManaged public var changeableField: String
    
    public var plainObject: PlainType {
        return .init(
            identifier: identifier,
            name: name,
            changeableField: changeableField
        )
    }
    
    public func update(from plain: PlainType) {
        self.identifier = plain.identifier
        self.name = plain.name
        self.changeableField = plain.changeableField
    }
}

public struct PlainTestEntity: TestCoreDataPlainObject, Equatable {
    public typealias ManagedType = TestEntity
    
    public let identifier: String
    let name: String
    var changeableField: String
    
    static func new() -> PlainTestEntity {
        return .init(identifier: UUID().uuidString, name: .random(), changeableField: .random())
    }
    
    static func identicalPredicate(with object: PlainTestEntity) -> TypedPredicate<ManagedType> {
        return \ManagedType.identifier == object.identifier
    }
}

protocol TestCoreDataPlainObject: ManagedTransformable {
    var changeableField: String { get set }
    
    static func new() -> Self
    static func identicalPredicate(with object: Self) -> TypedPredicate<Self.ManagedType>
}
