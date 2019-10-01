//
//  WordTranslation+CoreDataProperties.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 02/10/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//
//

import Foundation
import CoreData


extension WordTranslation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WordTranslation> {
        return NSFetchRequest<WordTranslation>(entityName: "WordTranslation")
    }

    @NSManaged public var created: Date!
    @NSManaged public var rawValue: String!
    @NSManaged public var translation: String!
    @NSManaged public var id: String!
    @NSManaged public var dictionary: NSSet?

}

// MARK: Generated accessors for dictionary
extension WordTranslation {

    @objc(addDictionaryObject:)
    @NSManaged public func addToDictionary(_ value: TranslationDictionary)

    @objc(removeDictionaryObject:)
    @NSManaged public func removeFromDictionary(_ value: TranslationDictionary)

    @objc(addDictionary:)
    @NSManaged public func addToDictionary(_ values: NSSet)

    @objc(removeDictionary:)
    @NSManaged public func removeFromDictionary(_ values: NSSet)

}
