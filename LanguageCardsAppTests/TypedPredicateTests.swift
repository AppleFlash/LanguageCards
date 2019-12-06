//
//  TypedPredicateTests.swift
//  LanguageCardsAppTests
//
//  Created by Vladislav Sedinkin on 06.12.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import Quick
import Nimble
import CoreData
@testable import LanguageCardsApp

class TypedPredicateTests: QuickSpec {
    private class Test: NSManagedObject {
        @objc var name: String = ""
        @objc var age: Int = 10
        @objc var list: [Int] = []
    }
    
    override func spec() {
        let name = UUID().uuidString
        let age = intRandom()
        let list = [intRandom(), intRandom()]
        
        context("equal predicate") {
            it("valid") {
                self.predicate(\Test.name == name, hasFormat: "name == \"\(name)\"")
            }
            it("not valid") {
                self.predicate(\Test.name == "", hasNotFormat: "name = \"\"")
            }
        }
        context("not equal predicate") {
            it("valid") {
                self.predicate(\Test.age != age, hasFormat: "age != \(age)")
            }
        }
        context("greater predicate") {
            it("valid") {
                self.predicate(\Test.age > age, hasFormat: "age > \(age)")
            }
        }
        context("greater or equal predicate") {
            it("valid") {
                self.predicate(\Test.age >= age, hasFormat: "age >= \(age)")
            }
        }
        context("less predicate") {
            it("valid") {
                self.predicate(\Test.age < age, hasFormat: "age < \(age)")
            }
        }
        context("less or equal predicate") {
            it("valid") {
                self.predicate(\Test.age <= age, hasFormat: "age <= \(age)")
            }
        }
        context("or between predicate") {
            it("valid") {
                let firstPredicate = \Test.name == name
                let secondPredicate = \Test.age == age
                let expectedFormat = "name == \"\(name)\" OR age == \(age)"
                
                self.predicate(firstPredicate || secondPredicate, hasFormat: expectedFormat)
            }
        }
        context("not predicate") {
            it("valid") {
                self.predicate(!(\Test.age == age), hasFormat: "NOT age == \(age)")
            }
        }
        context("in predicate") {
            it("valid") {
                let values = list.map(String.init).joined(separator: ", ")
                self.predicate(.key(\Test.age, in: list), hasFormat: "age IN {\(values)}")
            }
        }
        context("beginWith predicate") {
            it("valid") {
                let symbol = "n"
                self.predicate(.key(\Test.name, beginsWith: symbol), hasFormat: "name BEGINSWITH \"\(symbol)\"")
            }
        }
        context("endsWith predicate") {
            it("valid") {
                let symbol = "n"
                self.predicate(.key(\Test.name, endsWith: symbol), hasFormat: "name ENDSWITH \"\(symbol)\"")
            }
        }
        context("contains predicate") {
             it("valid") {
                 self.predicate(.key(\Test.list, contains: age), hasFormat: "list CONTAINS \(age)")
                self.predicate(.key(\Test.name, contains: name), hasFormat: "name CONTAINS \"\(name)\"")
             }
         }
    }
    
    private func predicate<T>(_ typePredicate: TypedPredicate<T>, hasFormat format: String, line: UInt = #line) {
        expect(typePredicate.predicate.predicateFormat, line: line) == format
    }
    
    private func predicate<T>(_ typePredicate: TypedPredicate<T>, hasNotFormat format: String, line: UInt = #line) {
        expect(typePredicate.predicate.predicateFormat, line: line) != format
    }
    
    private func intRandom() -> Int {
        return .random(in: 0...100)
    }
}
