//
//  PredicateTests.swift
//  LanguageCardsAppTests
//
//  Created by Vladislav Sedinkin on 06.11.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import Quick
import Nimble

@testable import LanguageCardsApp

class PredicateTests: QuickSpec {
    override func spec() {
        describe("predicate") {
            context("construct") {
                let firstRange = 0..<10
                let secondRange = 10..<20
                
                let firstPredicate = \PlainTestEntity.ManagedType.name == UUID().uuidString
                let secondPredicate = \PlainTestEntity.ManagedType.identifier == UUID().uuidString
                let firstFormat = firstPredicate.predicate
                
                let predicate = Predicate()
                    .batch(firstRange)
                    .filter(firstPredicate)
                    .batch(secondRange)
                    .filter(secondPredicate)
                let operations = predicate.build()
                
                it("should has valid count") {
                    expect(operations.count) == 2
                }
                
                it("should has valid range") {
                    expect(operations.first { $0.batch != nil }.flatMap { $0.batch }) == firstRange
                }
                
                it("should has valid predicate") {
                    expect(
                        operations.first { $0.filter != nil }.flatMap { $0.filter }?.predicate
                    ) == firstFormat
                }
            }
            
            context("wrong construct") {
                it("fail: no predicate") {
                    let predicate = LanguageCardsApp.Predicate<PlainTestEntity.ManagedType>().batch(0..<1)
                        .toSystemPredicate
                    expect(predicate).to(beNil())
                }
                it("fail: no payload") {
                    let predicate = LanguageCardsApp.Predicate<PlainTestEntity.ManagedType>().toSystemPredicate
                    expect(predicate).to(beNil())
                }
            }
        }
    }
}
