//
//  TranslationDictionary+CoreDataProperties.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 02/10/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//
//

import Foundation
import CoreData


extension TranslationDictionary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TranslationDictionary> {
        return NSFetchRequest<TranslationDictionary>(entityName: "TranslationDictionary")
    }

    @NSManaged public var text: String!
    @NSManaged public var word: WordTranslation!
    @NSManaged public var synonyms: NSSet?
    @NSManaged public var mean: NSSet?

}

// MARK: Generated accessors for synonyms
extension TranslationDictionary {

    @objc(addSynonymsObject:)
    @NSManaged public func addToSynonyms(_ value: WordSynonym)

    @objc(removeSynonymsObject:)
    @NSManaged public func removeFromSynonyms(_ value: WordSynonym)

    @objc(addSynonyms:)
    @NSManaged public func addToSynonyms(_ values: NSSet)

    @objc(removeSynonyms:)
    @NSManaged public func removeFromSynonyms(_ values: NSSet)

}

// MARK: Generated accessors for mean
extension TranslationDictionary {

    @objc(addMeanObject:)
    @NSManaged public func addToMean(_ value: WordMean)

    @objc(removeMeanObject:)
    @NSManaged public func removeFromMean(_ value: WordMean)

    @objc(addMean:)
    @NSManaged public func addToMean(_ values: NSSet)

    @objc(removeMean:)
    @NSManaged public func removeFromMean(_ values: NSSet)

}
