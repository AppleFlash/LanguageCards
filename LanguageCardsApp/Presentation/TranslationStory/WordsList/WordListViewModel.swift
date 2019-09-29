//
//  WordListViewModel.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 29/09/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactiveLists

protocol WordListOutput: class {
    var tableViewModel: Driver<TableViewModel> { get }
}

final class WordListViewModel {
    private let wordsService: SavedWordsService
    
    init(wordsService: SavedWordsService) {
        self.wordsService = wordsService
    }
}

extension WordListViewModel: WordListOutput {
    var tableViewModel: Driver<TableViewModel> {
        return .never()
    }
}
