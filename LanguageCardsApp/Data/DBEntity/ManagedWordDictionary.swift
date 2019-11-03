//
//  ManagedWordDictionary.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 04/11/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import CoreData

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
        
        self.original = plain.original
        
        let predicate = Predicate().filter(
            .key(
                \ManagedWordTranslation.translation,
                in: plain.translations.map { $0.translation }
            )
        )
        let existingObjects = context.getOrFetch(with: predicate)
        let newObjects = plain.translations
            .filter { plain in
                !existingObjects.contains { plain.identifier == $0.identifier }
            }
        .map { plain -> ManagedWordTranslation in
            let object = ManagedWordTranslation(context: context)
            object.update(from: plain)
            return object
        }
        
        translations = Set(existingObjects + newObjects)
    }
}

extension WordDictionary: ManagedTransformable {
    typealias ManagedType = ManagedWordDictionary

    var identifier: String {
        return original
    }
}

