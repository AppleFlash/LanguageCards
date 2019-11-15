//
//  ManagedWordDictionary.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 04/11/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import CoreData

@objc(ManagedWordDictionary)
final class ManagedWordDictionary: NSManagedObject {
    @NSManaged private(set) var original: String
    @NSManaged private(set) var translations: Set<ManagedWordTranslation>
}

extension ManagedWordDictionary: PlainTransformable {
    typealias PlainType = WordDictionary
    
    var plainObject: PlainType {
        return .init(original: original, translations: translations.map { $0.plainObject })
    }
    
    var identifier: String {
        return original
    }
    
    func update(from plain: PlainType) {
        guard let context = managedObjectContext else {
            fatalError()
        }
        
        original = plain.original
        
        let predicate = Predicate().filter(
            .key(
                \ManagedWordTranslation.translation,
                in: plain.translations.map { $0.translation }
            )
        )
        
        translations = context.getOrCreateCollection(
            predicate,
            using: plain.translations
        )
    }
}

extension WordDictionary: ManagedTransformable {
    typealias ManagedType = ManagedWordDictionary

    var identifier: String {
        return original
    }
}

