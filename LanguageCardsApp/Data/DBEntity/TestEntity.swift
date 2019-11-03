//
//  TestEntity.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 04/11/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import CoreData

@objc(TestEntity)
public class TestEntity: NSManagedObject, PlainTransformable {
    typealias PlainType = PlainTestEntity
    
    @NSManaged public var identifier: String
    @NSManaged public var name: String
    
    var plainObject: PlainType {
        return .init(
            identifier: identifier,
            name: name
        )
    }
    
    required convenience init() {
        fatalError()
    }
    
    func update(from plain: PlainType) {
        self.identifier = plain.identifier
        self.name = plain.name
    }
}

struct PlainTestEntity: ManagedTransformable, Equatable {
    typealias ManagedType = TestEntity
    
    let identifier: String
    var name: String
}

