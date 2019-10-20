//
//  WordTranslation.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 05/10/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import UIKit

struct RawTranslation: Decodable {
    enum Direction: String, Decodable {
        case enRu = "en-ru"
        case ruEn = "ru-en"
    }
    
    enum CodingKeys: String, CodingKey {
        case direction = "lang"
        case translations = "text"
    }
    
    var original: String = ""
    let direction: Direction
    let translations: [String]
}

struct RawDictionary {
    let original: String
    let translations: [RawDictionaryTranslation]
}

struct RawDictionaryTranslation {
    let original: String
    let translation: String
    let synonims: [String]?
    let means: [String]?
}

struct Word {
    let create: Date
    let translation: RawTranslation
    let dictionary: RawDictionary
    var progressHistory: [Bool]
}
