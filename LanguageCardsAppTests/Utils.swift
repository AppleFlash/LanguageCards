//
//  Utils.swift
//  LanguageCardsAppTests
//
//  Created by Vladislav Sedinkin on 07.11.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import UIKit

extension String {
    static func random(length: Int = 10) -> String {
        let characterSet = "qwertyuiop[]\';lkjhgfdsazxcvbnm,./QWERTYUIOPLKJHGFDSAZXCVBNM1234567890-="
        var newString = ""
        for _ in 0..<10 {
            newString += String(characterSet.randomElement() ?? Character(""))
        }
        
        return newString
    }
}
