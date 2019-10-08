//
//  WordTranslation.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 05/10/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import UIKit

struct WordTranslation {
    let created: Date
    let rawValue: String
    let translation: String
    let dictionary: [TranslationDictionary]?
}
