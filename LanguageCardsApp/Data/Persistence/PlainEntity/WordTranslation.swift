//
//  WordTranslation.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 05/10/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import Foundation

// Raw dictionary model

struct RawDictionaryResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case dictionary = "def"
    }
    
    var iden: String = ""
    let dictionary: [WordDictionary]
}

struct WordDictionary: Decodable {
    enum CodingKeys: String, CodingKey {
        case original = "text"
        case translations = "tr"
    }
    
    let original: String
    let translations: [WordTranslation]
}

struct WordTranslation: Decodable {
    enum CodingKeys: String, CodingKey {
        case synonims = "syn"
        case means = "mean"
        case translation = "text"
    }
    private struct RawSynonim: Decodable {
        let text: String
    }
    private struct RawMean: Decodable {
        let text: String
    }
    
    var translation: String
    let synonims: [String]?
    let means: [String]?
    
    init(
        translation: String,
        synonims: [String]?,
        means: [String]?
    ) {
        self.translation = translation
        self.synonims = synonims
        self.means = means
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        translation = try container.decode(String.self, forKey: .translation)
        
        if let rawSynonims = try container.decodeIfPresent([RawSynonim].self, forKey: .synonims) {
            synonims = rawSynonims.map { $0.text }
        } else {
            synonims = nil
        }
        if let rawMeans = try container.decodeIfPresent([RawMean].self, forKey: .means) {
            means = rawMeans.map { $0.text }
        } else {
            means = nil
        }
    }
}

//

struct Word {
    let create: Date
    let original: String
    let dictionary: WordDictionary
}
