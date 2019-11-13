//
//  CoreDataPersistenceTests.swift
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

class CoreDataMockService<T: TestCoreDataPlainObject> {
    var rawType: T.Type {
        return T.self
    }
    
    func makePlain() -> T {
        return T.new()
    }
    
    func save(
        object: T,
        using persistence: Persistence,
        file: String = #file,
        line: UInt = #line
    ) {
        expect(
            try persistence.save(object: object).toBlocking().first(),
            file: file,
            line: line
        ).toNot(throwError())
    }
    
    func save(
        objects: [T],
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
        using persistence: Persistence,
        file: String = #file,
        line: UInt = #line
    ) -> [T] {
        let objects = try? persistence
            .getObjects(T.self)
            .toBlocking()
            .first()
        expect(objects, file: file, line: line).toNot(beNil())
        
        return objects!
    }
    
    func get(
        with predicate: LanguageCardsApp.Predicate<T.ManagedType>,
        using persistence: Persistence,
        file: String = #file,
        line: UInt = #line
    ) -> T {
        let object: T?? = try? persistence.getObject(using: predicate)
            .toBlocking()
            .last()
        
        expect(object, file: file, line: line).toNot(beNil())
        
        return object!!
    }
    
    func delete(
        with predicate: LanguageCardsApp.Predicate<T.ManagedType>,
        using persistence: Persistence,
        file: String = #file,
        line: UInt = #line
    ) {
        expect(
            try persistence.delete(T.self, predicate: predicate)
                .toBlocking()
                .first(),
            file: file,
            line: line
        ).toNot(throwError())
    }
}

extension Array where Element: TestCoreDataPlainObject {
    func sortedById() -> [Element] {
        return sorted { $0.identifier < $1.identifier }
    }
}

class CoreDataPersistenceTests: QuickSpec {
    override func spec() {
        describe("core data") {
            var inMemoryPersistence: Persistence!
            var sqlPersistence: Persistence!
            var mock: CoreDataMockService<PlainTestParent>!
            
            beforeEach {
                self.clear(persistences: [inMemoryPersistence, sqlPersistence])
                inMemoryPersistence = CoreDataPersistence(coordinatorType: .inMemory, containerName: "TestLanguageCardsApp")
                sqlPersistence = CoreDataPersistence(coordinatorType: .SQLite, containerName: "TestLanguageCardsApp")
                mock = .init()
            }
            
            context("retrieve objects") {
                it("has valid array") {
                    let plain1 = mock.makePlain()
                    let plain2 = mock.makePlain()
                    let plainObjects = [plain1, plain2].sortedById()
                    
                    mock.save(objects: plainObjects, to: inMemoryPersistence)
                    let savedObjects = mock.getAll(using: inMemoryPersistence).sortedById()
                    
                    expect(savedObjects) == plainObjects
                }
                
                it("has valid object") {
                    let plain = mock.makePlain()
                    mock.save(object: plain, using: inMemoryPersistence)
                    
                    let predicate = Predicate().filter(mock.rawType.identicalPredicate(with: plain))
                    let savedObject = mock.get(with: predicate, using: inMemoryPersistence)
                    
                    expect(savedObject) == plain
                }
            }
            
            context("change operations") {
                it("valid insert") {
                    mock.save(object: mock.makePlain(), using: inMemoryPersistence)
                }
                
                it("update existing object") {
                    var plain = mock.makePlain()
                    mock.save(object: plain, using: inMemoryPersistence)
                    plain.changeableField = .random()
                    mock.save(object: plain, using: inMemoryPersistence)
                    
                    let savedObjects = mock.getAll(using: inMemoryPersistence)
                    
                    expect(savedObjects).to(haveCount(1))
                    expect(savedObjects.first) == plain
                }
                
                it("delete single object") {
                    var objects = [mock.makePlain(), mock.makePlain()].sortedById()
                    let deletedObject = objects.remove(at: 0)
                    self.clear(persistences: [sqlPersistence])
                    
                    expect(mock.getAll(using: sqlPersistence)).to(beEmpty())
                    mock.save(objects: objects, to: sqlPersistence)
                    
                    let predicate = Predicate().filter(mock.rawType.identicalPredicate(with: deletedObject))
                    mock.delete(with: predicate, using: sqlPersistence)
                    let savedObjects = mock.getAll(using: sqlPersistence).sortedById()
                    
                    expect(savedObjects) == objects
                }
            }
            
            context("utils") {
                it("executes in valid queue") {
                    let disposeBag = DisposeBag()
                    waitUntil { done in
                        inMemoryPersistence.getObjects(mock.rawType)
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
    
    private func clear(persistences: [Persistence?]) {
        persistences.forEach {
            _ = try? $0?.clear().toBlocking().first()
        }
    }
}
