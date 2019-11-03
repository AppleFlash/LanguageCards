//
//  ManagedWordTranslation.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 04/11/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import CoreData

final class ManagedWordTranslation: NSManagedObject {
    @NSManaged private(set) var translation: String
    @NSManaged private(set) var synonims: [String]
    @NSManaged private(set) var means: [String]
}

extension ManagedWordTranslation: PlainTransformable {
    typealias PlainType = WordTranslation
    
    var plainObject: PlainType {
        return .init(translation: translation, synonims: synonims, means: means)
    }
    
    var identifier: String {
        return translation
    }
    
    func update(from plain: PlainType) {
        self.translation = plain.translation
        self.synonims = plain.synonims ?? []
        self.means = plain.means ?? []
    }
}

extension WordTranslation: ManagedTransformable {
    typealias ManagedType = ManagedWordTranslation
    
    var identifier: String {
        return translation
    }
}
