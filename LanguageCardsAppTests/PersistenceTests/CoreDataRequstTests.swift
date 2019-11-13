//
//  CoreDataRequstTests.swift
//  LanguageCardsAppTests
//
//  Created by Vladislav Sedinkin on 08.11.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import Quick
import Nimble
import CoreData

@testable import LanguageCardsApp

class CoreDataRequstTests: QuickSpec {
    override func spec() {
        describe("request") {
            context("constructing") {
                var fetchRequest: NSFetchRequest<NSFetchRequestResult>!
                beforeEach {
                    fetchRequest = .init()
                }
                
                it("should be valid batched and has predicate") {
                    let range = 10..<20
                    let predicate = Predicate()
                        .filter(\PlainTestEntity.ManagedType.identifier == "123")
                        .batch(range)
                        
                    CoreDataRequest.apply(predicate, to: fetchRequest)
                    
                    expect(fetchRequest.predicate).toNot(beNil())
                    expect(fetchRequest.predicate) == fetchRequest.predicate
                    expect(fetchRequest.fetchLimit) == range.upperBound - range.lowerBound
                    expect(fetchRequest.fetchOffset) == range.lowerBound
                }
                
                it("should has one limit and zero offset") {
                    let range = 0..<1
                    let predicate = LanguageCardsApp.Predicate<PlainTestEntity.ManagedType>().batch(range)
                    CoreDataRequest.apply(predicate, to: fetchRequest)
                    
                    expect(fetchRequest.fetchLimit) == 1
                    expect(fetchRequest.fetchOffset) == 0
                }
            }
        }
    }
}
