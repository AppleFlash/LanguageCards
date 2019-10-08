//
//  ManagedWordMean+CoreDataClass.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 05/10/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedWordMean)
public class ManagedWordMean: NSManagedObject, ManagedInitializableType {
    typealias PlainType = WordMean
    
    var plainObject: PlainType {
        return WordMean(text: self.text ?? "", identifier: "")
    }
    
    required convenience init() {
        fatalError()
    }
    
    func update(from plain: PlainType) {
        self.text = plain.text
    }
}

extension WordMean: ManagedTransformable {
    typealias ManagedType = ManagedWordMean
}
