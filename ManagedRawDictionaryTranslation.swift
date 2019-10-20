//
//  ManagedRawDictionaryTranslation.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 20.10.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//
//

import Foundation
import CoreData

public class ManagedRawDictionaryTranslation: NSManagedObject {
    @NSManaged public var original: String
    @NSManaged public var translation: String
    @NSManaged public var synonims: [NSString]?
    @NSManaged public var means: [NSString]?
}

extension ManagedRawDictionaryTranslation: PlainTransformable {
    typealias PlainType = RawDictionaryTranslation
    
    public var identifier: String {
        return original
    }
    
    var plainObject: PlainType {
        return .init(
            original: original,
            translation: translation,
            synonims: synonims as [String]?,
            means: means as [String]?
        )
    }
    
    func update(from plain: PlainType) {
        self.translation = plain.translation
        self.synonims = plain.synonims as [NSString]?
        self.means = plain.means as [NSString]?
    }
}

extension RawDictionaryTranslation: ManagedTransformable {
    typealias ManagedType = ManagedRawDictionaryTranslation
    
    var identifier: String {
        return translation
    }
}
