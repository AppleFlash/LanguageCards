//
//  QuickCoreDataPersistenceTests.swift
//  LanguageCardsAppTests
//
//  Created by Vladislav Sedinkin on 07.11.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import Quick
import Nimble
import CoreData
import RxSwift
import RxCocoa
import RxBlocking
import RxTest

@testable import LanguageCardsApp

class QuickCoreDataPersistenceTests: QuickSpec {
    private let sortBlock: (PlainTestEntity, PlainTestEntity) -> Bool = { $0.identifier < $1.identifier }
    
    override func spec() {
        describe("core data") {
            var inMemoryPersistence: Persistence!
            var sqlPersistence: Persistence!
            
            beforeEach {
                self.clear(persistences: [inMemoryPersistence, sqlPersistence])
                inMemoryPersistence = CoreDataPersistence(coordinatorType: .inMemory)
                sqlPersistence = CoreDataPersistence(coordinatorType: .SQLite)
            }
            
            context("retrieve objects") {
                it("has valid array") {
                    let plain1 = self.makePlain()
                    let plain2 = self.makePlain()
                    let plainObjects = [plain1, plain2].sorted(by: self.sortBlock)
                    
                    self.saveObjects(plainObjects, to: inMemoryPersistence)
                    let savedObjects = self.getAll(from: inMemoryPersistence)?.sorted(by: self.sortBlock)
                    
                    expect(savedObjects) == plainObjects
                }
                
                it("has valid object") {
                    let plain = self.makePlain()
                    self.saveObject(plain, to: inMemoryPersistence)
                    let predicate = Predicate().filter(\PlainTestEntity.ManagedType.identifier == plain.identifier)
                    let savedObject: PlainTestEntity?? = try? inMemoryPersistence
                    .getObject(with: predicate)
                        .toBlocking()
                        .first()
                    
                    expect(savedObject) == plain
                }
            }
            
            context("change operations") {
                it("valid insert") {
                    self.saveObject(self.makePlain(), to: inMemoryPersistence)
                }
                
                it("update existing object") {
                    var plain = self.makePlain()
                    self.saveObject(plain, to: inMemoryPersistence)
                    plain.name = .random()
                    self.saveObject(plain, to: inMemoryPersistence)
                    
                    let savedObjects = self.getAll(from: inMemoryPersistence)
                    
                    expect(savedObjects).to(haveCount(1))
                    expect(savedObjects?.first) == plain
                }
                
                it("delete single object") {
                    var objects = [self.makePlain(), self.makePlain()].sorted(by: self.sortBlock)
                    let deletedObject = objects.remove(at: 0)
                    self.clear(persistences: [sqlPersistence])
                    
                    expect(self.getAll(from: sqlPersistence)).to(beEmpty())
                    self.saveObjects(objects, to: sqlPersistence)
                    
                    let predicate = Predicate().filter(\PlainTestEntity.ManagedType.identifier == deletedObject.identifier)
                    let savedObjects: [PlainTestEntity]? = try? sqlPersistence
                        .delete(PlainTestEntity.self, predicate: predicate)
                        .flatMap { sqlPersistence.getAll(PlainTestEntity.self) }
                        .toBlocking()
                        .first()?
                        .sorted(by: self.sortBlock)
                    
                    expect(savedObjects) == objects
                }
            }
            
            context("utils") {
                it("executes in valid queue") {
                    let disposeBag = DisposeBag()
                    waitUntil { done in
                        inMemoryPersistence.getAll(PlainTestEntity.self)
                            .subscribe(onSuccess: { _ in
                                expect(Thread.isMainThread) == false
                                done()
                            })
                            .disposed(by: disposeBag)
                    }
                }
            }
        }
    }
}

private extension QuickCoreDataPersistenceTests {
    func clear(persistences: [Persistence?]) {
        persistences.forEach {
            _ = try? $0?.clear().toBlocking().first()
        }
    }
    
    func makePlain(_ name: String = .random()) -> PlainTestEntity {
        return .init(identifier: UUID().uuidString, name: name)
    }
    
    func saveObject(
        _ object: PlainTestEntity,
        to persistence: Persistence,
        file: String = #file,
        line: UInt = #line
    ) {
        expect(
            try persistence.save(object: object).toBlocking().first(),
            file: file,
            line: line
        ).toNot(throwError())
    }
    
    func saveObjects(
        _ objects: [PlainTestEntity],
        to persistence: Persistence,
        file: String = #file,
        line: UInt = #line
    ) {
        expect(
            try persistence.save(objects: objects).toBlocking().first(),
            file: file,
            line: line
        ).toNot(throwError())
    }
    
    func getAll(
        from persistence: Persistence,
        file: String = #file,
        line: UInt = #line
    ) -> [PlainTestEntity]? {
        let objects = try? persistence
            .getAll(PlainTestEntity.self)
            .toBlocking()
            .first()
        expect(objects, file: file, line: line).toNot(beNil())
        
        return objects
    }
}
