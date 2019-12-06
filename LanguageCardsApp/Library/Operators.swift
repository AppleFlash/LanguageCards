//
//  Operators.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 09/10/2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import CoreData

open class TypedPredicate<T: NSManagedObject>: NSPredicate {
    public let predicate: NSPredicate
    
    public init(predicate: NSPredicate) {
        self.predicate = predicate
        
        super.init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension KeyPath where Root: NSManagedObject {
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

func == <T: NSManagedObject, V>(_ keyPath: KeyPath<T, V>, value: V) -> TypedPredicate<T> {
    return keyPath.predicate(value: value, op: .equalTo)
}

func != <T: NSManagedObject, V>(_ keyPath: KeyPath<T, V>, value: V) -> TypedPredicate<T> {
    return keyPath.predicate(value: value, op: .notEqualTo)
}

func > <T: NSManagedObject, V>(_ keyPath: KeyPath<T, V>, value: V) -> TypedPredicate<T> {
    return keyPath.predicate(value: value, op: .greaterThan)
}

func >= <T: NSManagedObject, V>(_ keyPath: KeyPath<T, V>, value: V) -> TypedPredicate<T> {
    return keyPath.predicate(value: value, op: .greaterThanOrEqualTo)
}

func < <T: NSManagedObject, V>(_ keyPath: KeyPath<T, V>, value: V) -> TypedPredicate<T> {
    return keyPath.predicate(value: value, op: .lessThan)
}

func <= <T: NSManagedObject, V>(_ keyPath: KeyPath<T, V>, value: V) -> TypedPredicate<T> {
    return keyPath.predicate(value: value, op: .lessThanOrEqualTo)
}

public func && <T: NSManagedObject>(
    _ leftPredicate: TypedPredicate<T>,
    rightPredicate: TypedPredicate<T>
) -> TypedPredicate<T> {
    return .init(
        predicate: NSCompoundPredicate(
            type: .and,
            subpredicates: [leftPredicate.predicate, rightPredicate.predicate]
        )
    )
}

public func || <T: NSManagedObject>(_ leftPredicate: TypedPredicate<T>, rightPredicate: TypedPredicate<T>) -> TypedPredicate<T> {
    return .init(predicate: NSCompoundPredicate(type: .or, subpredicates: [leftPredicate.predicate, rightPredicate.predicate]))
}

public prefix func ! <T: NSManagedObject>(_ predicate: TypedPredicate<T>) -> TypedPredicate<T> {
    return .init(predicate: NSCompoundPredicate(type: .not, subpredicates: [predicate.predicate]))
}

extension TypedPredicate {
    static func key<T: NSManagedObject, V>(_ keyPath: KeyPath<T, V>, in value: [V]) -> TypedPredicate<T> {
        return keyPath.predicate(value: value, op: .in)
    }
    
    static func key<T: NSManagedObject, V>(
        _ keyPath: KeyPath<T, V>,
        beginsWith value: V,
        options: NSComparisonPredicate.Options = []
    ) -> TypedPredicate<T> {
        return keyPath.predicate(value: value, op: .beginsWith, options: options)
    }
    
    static func key<T: NSManagedObject, V>(
        _ keyPath: KeyPath<T, V>,
        endsWith value: V,
        options: NSComparisonPredicate.Options = []
    ) -> TypedPredicate<T> {
        return keyPath.predicate(value: value, op: .endsWith, options: options)
    }
    
    static func key<T: NSManagedObject, V>(
        _ keyPath: KeyPath<T, V>,
        contains value: V,
        options: NSComparisonPredicate.Options = []
    ) -> TypedPredicate<T> {
        return keyPath.predicate(value: value, op: .contains, options: options)
    }
    
    static func key<T: NSManagedObject, V: Sequence, E>(
        _ keyPath: KeyPath<T, V>,
        contains value: E,
        options: NSComparisonPredicate.Options = []
    ) -> TypedPredicate<T> where V.Element == E {
        return keyPath.predicate(value: value, op: .contains, options: options)
    }
}

