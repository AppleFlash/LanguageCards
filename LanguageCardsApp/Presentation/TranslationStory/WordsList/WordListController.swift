//
//  WordListController.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 29/09/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import UIKit

final class WordListController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyWordsLabel: UILabel!
    @IBOutlet private weak var startTrainingButton: UIButton!
    
    var output: WordListOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
