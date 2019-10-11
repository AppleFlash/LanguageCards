//
//  CoreDataRequest.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 12.10.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import CoreData

final class CoreDataRequest {
    static func apply<ResultType: NSFetchRequestResult, PredicateType: PlainTransformable>(
        _ predicate: Predicate<PredicateType>,
        to fetchRequest: NSFetchRequest<ResultType>
    ) {
        predicate.build().forEach { operation in
            switch operation {
            case let .batch(range):
                fetchRequest.fetchLimit = range.upperBound - range.lowerBound
                fetchRequest.fetchOffset = range.lowerBound
            case let .filter(typedPredicate):
                fetchRequest.predicate = typedPredicate.predicate
            }
        }
    }
}
