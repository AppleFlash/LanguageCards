//
//  WordSynonym+CoreDataProperties.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 02/10/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//
//

import Foundation
import CoreData


extension WordSynonym {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WordSynonym> {
        return NSFetchRequest<WordSynonym>(entityName: "WordSynonym")
    }

    @NSManaged public var text: String!
    @NSManaged public var dictionary: TranslationDictionary!

}
