//
//  Operators.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 09/10/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import Foundation

class TypedPredicate<T>: NSPredicate {
    let predicate: NSPredicate
    
    init(predicate: NSPredicate) {
        self.predicate = predicate
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension KeyPath {
    func predicate<V>(
        value: V,
        op: NSComparisonPredicate.Operator,
        options: NSComparisonPredicate.Options = []
    ) -> TypedPredicate<Root> {
        let leftExpression = NSExpression(forKeyPath: self)
        let rightExpression = NSExpression(forConstantValue: value)
        
        let predicate = NSComparisonPredicate(
            leftExpression: leftExpression,
            rightExpression: rightExpression,
            modifier: .direct,
            type: op,
            options: options
        )
        
        return TypedPredicate(predicate: predicate)
    }
}

func == <T, V> (_ keyPath: KeyPath<T, V>, value: V) -> TypedPredicate<T> {
    return keyPath.predicate(value: value, op: .equalTo)
}

func != <T, V> (_ keyPath: KeyPath<T, V>, value: V) -> TypedPredicate<T> {
    return keyPath.predicate(value: value, op: .notEqualTo)
}

func > <T, V> (_ keyPath: KeyPath<T, V>, value: V) -> TypedPredicate<T> {
    return keyPath.predicate(value: value, op: .greaterThan)
}

func >= <T, V> (_ keyPath: KeyPath<T, V>, value: V) -> TypedPredicate<T> {
    return keyPath.predicate(value: value, op: .greaterThanOrEqualTo)
}

func < <T, V> (_ keyPath: KeyPath<T, V>, value: V) -> TypedPredicate<T> {
    return keyPath.predicate(value: value, op: .lessThan)
}

func <= <T, V> (_ keyPath: KeyPath<T, V>, value: V) -> TypedPredicate<T> {
    return keyPath.predicate(value: value, op: .lessThanOrEqualTo)
}

public func && <P1: NSPredicate, P2: NSPredicate>(_ leftPredicate: P1, rightPredicate: P2) -> NSPredicate {
    return NSCompoundPredicate(type: .and, subpredicates: [leftPredicate, rightPredicate])
}

public func || <P1: NSPredicate, P2: NSPredicate>(_ leftPredicate: P1, rightPredicate: P2) -> NSPredicate {
    return NSCompoundPredicate(type: .or, subpredicates: [leftPredicate, rightPredicate])
}

public prefix func ! <T: NSPredicate>(_ predicate: T) -> NSPredicate {
    return NSCompoundPredicate(type: .not, subpredicates: [predicate])
}

extension TypedPredicate {
    static func key<T, V>(_ keyPath: KeyPath<T, V>, in value: [V]) -> TypedPredicate<T> {
        return keyPath.predicate(value: value, op: .in)
    }
    
    static func key<T, V>(
        _ keyPath: KeyPath<T, V>,
        beginsWith value: V,
        options: NSComparisonPredicate.Options = []
    ) -> TypedPredicate<T> {
        return keyPath.predicate(value: value, op: .beginsWith, options: options)
    }
    
    static func key<T, V>(
        _ keyPath: KeyPath<T, V>,
        endsWith value: V,
        options: NSComparisonPredicate.Options = []
    ) -> TypedPredicate<T> {
        return keyPath.predicate(value: value, op: .endsWith, options: options)
    }
    
    static func key<T, V>(
        _ keyPath: KeyPath<T, V>,
        contains value: V,
        options: NSComparisonPredicate.Options = []
    ) -> TypedPredicate<T> {
        return keyPath.predicate(value: value, op: .contains, options: options)
    }
}
