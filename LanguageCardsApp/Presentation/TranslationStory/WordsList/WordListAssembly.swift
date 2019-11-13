//
//  WordListAssembly.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 30/09/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import UIKit

protocol ModuleAssemply {
    associatedtype Controller: UIViewController
    
    func assemblyModule() -> Controller
}

final class WordListAssembly: ModuleAssemply {
    func assemblyModule() -> UINavigationController {
        let viewModel = WordListViewModel(wordsService: SavedWordsServiceImp())
        let navigationController = UIStoryboard(name: "WordList", bundle: .main).instantiateViewController(withIdentifier: "WordList") as! UINavigationController
        let controller = navigationController.topViewController as! WordListController
        controller.output = viewModel
        
        return navigationController
    }
}
