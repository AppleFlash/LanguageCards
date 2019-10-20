//
//  ManagedRawTranslation.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 20.10.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//
//

import Foundation
import CoreData

public class ManagedRawTranslation: NSManagedObject {
    @NSManaged public var direction: String
    @NSManaged public var translations: [NSString]
    @NSManaged public var original: String
}

extension ManagedRawTranslation: PlainTransformable {
    typealias PlainType = RawTranslation
    
    public var identifier: String {
        return original
    }
    
    var plainObject: PlainType {
        return .init(
            original: original,
            direction: RawTranslation.Direction(rawValue: direction)!,
            translations: translations as [String]
        )
    }
    
    func update(from plain: PlainType) {
        self.direction = plain.direction.rawValue
        self.translations = plain.translations as [NSString]
        self.original = plain.original
    }
}

extension RawTranslation: ManagedTransformable {
    typealias ManagedType = ManagedRawTranslation
    
    var identifier: String {
        return original
    }
}
