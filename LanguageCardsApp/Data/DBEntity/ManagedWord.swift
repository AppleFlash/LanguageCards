//
//  ManagedWord.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 04/11/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import CoreData

final class ManagedWord: NSManagedObject {
    @NSManaged private(set) var create: Date
    @NSManaged private(set) var original: String
    @NSManaged private(set) var dictionary: ManagedWordDictionary
}

extension ManagedWord: PlainTransformable {
    typealias PlainType = Word
    
    var plainObject: PlainType {
        return Word(create: create, original: original, dictionary: dictionary.plainObject)
    }
    
    var identifier: String {
        return original
    }
    
    func update(from plain: PlainType) {
        guard let context = managedObjectContext else {
            fatalError()
        }
        
        create = plain.create
        original = plain.original
        
        let predicate = Predicate().filter(\ManagedWordDictionary.original == original).batch(0..<1)
        let dictionaryObject: ManagedWordDictionary
        if let existingObject = context.getOrFetch(with: predicate).first {
            dictionaryObject = existingObject
        } else {
            dictionaryObject = .init(context: context)
        }
        
        dictionaryObject.update(from: plain.dictionary)
        
        dictionary = dictionaryObject
    }
}

extension Word: ManagedTransformable {
    typealias ManagedType = ManagedWord
    
    var identifier: String {
        return original
    }
}

