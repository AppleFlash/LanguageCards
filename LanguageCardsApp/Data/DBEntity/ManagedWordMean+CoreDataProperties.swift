//
//  ManagedWordMean+CoreDataProperties.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 05/10/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedWordMean {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedWordMean> {
        return NSFetchRequest<ManagedWordMean>(entityName: "WordMean")
    }

    @NSManaged public var text: String!
//    @NSManaged public var dictionary: ManagedTranslationDictionary?

}
