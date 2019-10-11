//
//  PredicateTests.swift
//  LanguageCardsAppTests
//
//  Created by Vladislav Sedinkin on 12.10.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import XCTest

@testable import LanguageCardsApp

class PredicateTests: XCTestCase {
    func testConstructPredicate() {
        let firstRange = 0..<10
        let secondRange = 10..<20
        
        let firstPredicate = \PlainTestEntity.ManagedType.name == UUID().uuidString
        let secondPredicate = \PlainTestEntity.ManagedType.identifier == UUID().uuidString
        let firstFormat = firstPredicate.predicate.predicateFormat
        
        let predicate = Predicate()
            .batch(firstRange)
            .filter(firstPredicate)
            .batch(secondRange)
            .filter(secondPredicate)
        
        let operations = predicate.build()
        
        XCTAssertTrue(operations.count == 2, "actual count \(operations.count)")
        let range = operations.first { $0.batch != nil }.flatMap { $0.batch }
        XCTAssertNotNil(range)
        XCTAssertTrue(range == firstRange, "actual range \(range!)")
        
        let standardPredicate = operations.first { $0.filter != nil }.flatMap { $0.filter }?.predicate
        XCTAssertNotNil(standardPredicate)
        XCTAssertTrue(standardPredicate!.predicateFormat == firstFormat, "actual format \(standardPredicate!.predicateFormat)")
    }
    
    func testConvertWrongToStandartPredicate() {
        let firstPredicate = Predicate<PlainTestEntity.ManagedType>().batch(0..<1)
        
        let secondPredicate = Predicate<PlainTestEntity.ManagedType>()
        
        let firstFormat = firstPredicate.toSystemPredicate?.predicateFormat
        XCTAssertNil(firstFormat, "actual format \(firstFormat!)")
        
        let secondFormat = secondPredicate.toSystemPredicate?.predicateFormat
        XCTAssertNil(secondFormat, "actual format \(secondFormat!)")
    }
    
    func testConvertRightToStandartPredicate() {
        let typedPredicate = \PlainTestEntity.ManagedType.identifier == UUID().uuidString
        let actualFormat = typedPredicate.predicate.predicateFormat
        let predicate = Predicate().filter(typedPredicate)
        
        let receivedFormat = predicate.toSystemPredicate?.predicateFormat
        XCTAssertNotNil(receivedFormat)
        XCTAssertTrue(actualFormat == receivedFormat, "actual format \(receivedFormat!)")
    }
}
