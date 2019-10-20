//
//  Predicate.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 12.10.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import Foundation

final class Predicate<T: PlainTransformable> {
    enum Operation: Hashable {
        case batch(Range<Int>)
        case filter(TypedPredicate<T>)
        
        private var type: String {
            switch self {
            case .batch:
                return "batch"
            case .filter:
                return "filter"
            }
        }
        
        var batch: Range<Int>? {
            if case let .batch(batch) = self {
                return batch
            } else {
                return nil
            }
        }
        
        var filter: TypedPredicate<T>? {
            if case let .filter(predicate) = self {
                return predicate
            } else {
                return nil
            }
        }
        
        static func == (lhs: Operation, rhs: Operation) -> Bool {
            return lhs.type == rhs.type
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(type)
        }
        
        var hashValue: Int { return type.hashValue }
    }
    
    static func from(predicate: NSPredicate) -> Predicate<T> {
        return Predicate().filter(.init(predicate: predicate))
    }
    
    private var operations: Set<Operation> = []
    
    var toSystemPredicate: NSPredicate? {
        return operations.first { $0.filter != nil }.flatMap { $0.filter }?.predicate
    }
    
    func batch(_ range: Range<Int>) -> Predicate {
        operations.insert(.batch(range))
        return self
    }
    
    func filter(_ typedPredicate: TypedPredicate<T>) -> Predicate {
        operations.insert(.filter(typedPredicate))
        return self
    }
    
    func build() -> Set<Operation> {
        return operations
    }
}
