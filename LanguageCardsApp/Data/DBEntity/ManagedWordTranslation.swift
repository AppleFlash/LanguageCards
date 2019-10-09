//
//  ManagedWordTranslation.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 05/10/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedWordTranslation)
public class ManagedWordTranslation: NSManagedObject, ManagedInitializableType {
    typealias PlainType = WordTranslation
    
    @NSManaged public var identifier: String
    @NSManaged public var created: Date
    @NSManaged public var means: [String]?
    @NSManaged public var original: String
    @NSManaged public var synonims: [String]?
    @NSManaged public var translation: String
    
    var plainObject: PlainType {
        return .init(
            identifier: identifier,
            created: created,
            means: means ?? [],
            original: original,
            synonims: synonims ?? [],
            translation: translation
        )
    }
    
    required convenience init() {
        fatalError()
    }
    
    func update(from plain: PlainType) {
        self.identifier = plain.identifier
        self.created = plain.created
        self.means = plain.means
        self.original = plain.original
        self.synonims = plain.synonims
        self.translation = plain.translation
    }
}

extension WordTranslation: ManagedTransformable {
    typealias ManagedType = ManagedWordTranslation
}

//

@objc(TestEntity)
public class TestEntity: NSManagedObject, ManagedInitializableType {
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

struct PlainTestEntity: ManagedTransformable {
    typealias ManagedType = TestEntity
    
    let identifier: String
    let name: String
}
