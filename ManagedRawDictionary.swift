//
//  ManagedRawDictionary.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 20.10.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//
//

import Foundation
import CoreData

public class ManagedRawDictionary: NSManagedObject {
    @NSManaged public var original: String
    @NSManaged public var translations: NSSet?
}

extension ManagedRawDictionary: PlainTransformable {
    typealias PlainType = RawDictionary
    
    public var identifier: String {
        return original
    }
    
    var plainObject: PlainType {
        return .init(
            original: original,
            translations: translations?.compactMap { $0 as? ManagedRawDictionaryTranslation }.map { $0.plainObject } ?? []
        )
    }
    
    func update(from plain: PlainType) {
        guard let context = managedObjectContext else {
            fatalError()
        }
        
        self.original = plain.original
        
        let typedPredicate: TypedPredicate<RawDictionaryTranslation.ManagedType> = .key(
            \RawDictionaryTranslation.ManagedType.original,
            in: plain.translations.map { $0.original }
        )
        let predicate = Predicate().filter(typedPredicate)
        
        var managedTranslations: [ManagedRawDictionaryTranslation] = managedObjectContext?.getOrFetch(with: predicate) ?? []
        
        let existingItems = plain.translations.filter { item in managedTranslations.contains { $0.identifier == item.identifier } }
        let newItems = plain.translations.filter { item in managedTranslations.contains { $0.identifier != item.identifier } }
        
        managedTranslations.forEach { managedTranslation in
            if let firstPlain = existingItems.first(where: { $0.identifier == managedTranslation.identifier }) {
                managedTranslation.update(from: firstPlain)
            }
        }
        
        managedTranslations.append(
            contentsOf: newItems.map {
                let newManagedItem = ManagedRawDictionaryTranslation(context: context)
                newManagedItem.update(from: $0)
                return newManagedItem
            }
        )
    }
}

extension RawDictionary: ManagedTransformable {
    typealias ManagedType = ManagedRawDictionary
    
    public var identifier: String {
        return original
    }
}
