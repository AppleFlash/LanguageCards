//
//  CoreDataPersistenceTests.swift
//  LanguageCardsAppTests
//
//  Created by Vladislav Sedinkin on 10.10.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import XCTest
import CoreData
import RxSwift
import RxCocoa
import RxBlocking
import RxTest

@testable import LanguageCardsApp

class CoreDataPersistenceTests: XCTestCase {
    private static var inMemoryPersistence: Persistence!
    private static var sqlPersistence: Persistence!
    
    private var disposeBag: DisposeBag = .init()
    private let sortBlock: (PlainTestEntity, PlainTestEntity) -> Bool = { $0.identifier < $1.identifier }
    
    override func setUp() {
        super.setUp()
        
        clearPersistences()
        disposeBag = .init()
        initPersistences()
    }
    
    func testInsertNewObject() {
        let plain = makePlain("1")
        
        let insertExpectation = expectation(description: "insert expectation")
        
        CoreDataPersistenceTests.inMemoryPersistence.save(object: plain)
            .subscribe(onSuccess: {
                insertExpectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [insertExpectation], timeout: 1)
    }
    
    func testGetObjects() {
        let plain1 = makePlain("1")
        let plain2 = makePlain("2")
        let plainObjects = [plain1, plain2].sorted(by: sortBlock)
        
        saveObjects(plainObjects, to: CoreDataPersistenceTests.inMemoryPersistence)
        
        let savedObjects: [PlainTestEntity]? = try? CoreDataPersistenceTests.inMemoryPersistence
            .getAll(PlainTestEntity.self)
            .toBlocking()
            .first()
        let sortedSavedObjects = savedObjects!.sorted(by: sortBlock)
        
        XCTAssertTrue(plainObjects == sortedSavedObjects)
    }
    
    func testGetSingleObject() {
        let plain = makePlain("name")
        saveObject(plain, to: CoreDataPersistenceTests.inMemoryPersistence)
        
        
        let predicate = Predicate().filter(\PlainTestEntity.ManagedType.identifier == plain.identifier)
        let savedObject: BlockingObservable<PlainTestEntity?> = CoreDataPersistenceTests.inMemoryPersistence
            .getObject(with: predicate)
            .toBlocking()
        let plainObject = try! savedObject.first()!!
        
        XCTAssertEqual(plain, plainObject, "\(plain) does not equal to \(plainObject)")
    }
    
    func testThatPersistenceExecutesInNonMainThread() {
        let threadExpectation = expectation(description: "thread expectation")
        
        DispatchQueue.main.async {
            CoreDataPersistenceTests.inMemoryPersistence.getAll(PlainTestEntity.self)
                .subscribe(onSuccess: { (obj: [PlainTestEntity]) in
                    threadExpectation.fulfill()
                    XCTAssertFalse(Thread.isMainThread)
                })
                .disposed(by: self.disposeBag)
        }
        
        wait(for: [threadExpectation], timeout: 1)
    }
    
    func testUpdateExistingEntity() {
        var plain = makePlain("1")
        saveObject(plain, to: CoreDataPersistenceTests.inMemoryPersistence)

        let newName = "changed"
        plain.name = newName

        XCTAssertNotNil(try? CoreDataPersistenceTests.inMemoryPersistence.save(object: plain).toBlocking().first())
        
        let predicate = Predicate().filter(\PlainTestEntity.ManagedType.identifier == plain.identifier)
        let savedObject: [PlainTestEntity] = try! CoreDataPersistenceTests.inMemoryPersistence
            .get(predicate)
            .toBlocking()
            .first()!
        XCTAssertEqual(savedObject.count, 1, "Actual count \(savedObject.count)")
        
        XCTAssertEqual(plain, savedObject.first, "\(plain) does not equal to \(savedObject)")
    }
    
    func testDeleteSingleEntity() {
        var objects = [makePlain("1"), makePlain("2")].sorted(by: sortBlock)
        let deletedObject = objects.remove(at: 0)
        clearPersistences()
        saveObjects(objects, to: CoreDataPersistenceTests.sqlPersistence)
        
        let predicate = Predicate().filter(\PlainTestEntity.ManagedType.identifier == deletedObject.identifier)
        let savedObjects: [PlainTestEntity]? = try? CoreDataPersistenceTests.sqlPersistence
            .delete(PlainTestEntity.self, predicate: predicate)
            .flatMap {
                CoreDataPersistenceTests.sqlPersistence.getAll(PlainTestEntity.self)
            }
            .toBlocking()
            .first()?
            .sorted(by: sortBlock)
        
        XCTAssertTrue(savedObjects!.count == objects.count, "actual count \(savedObjects!.count)")
        XCTAssertEqual(objects, savedObjects)
    }
}

private extension CoreDataPersistenceTests {
    func initPersistences() {
        CoreDataPersistenceTests.inMemoryPersistence = CoreDataPersistence(coordinatorType: .inMemory)
        CoreDataPersistenceTests.sqlPersistence = CoreDataPersistence(coordinatorType: .SQLite)
    }
    
    func clearPersistences() {
        _ = try? CoreDataPersistenceTests.inMemoryPersistence?.clear().toBlocking().first()
        _ = try? CoreDataPersistenceTests.sqlPersistence?.clear().toBlocking().first()
    }
    
    func makePlain(_ name: String) -> PlainTestEntity {
        return .init(identifier: UUID().uuidString, name: name)
    }
    
    func saveObject(_ object: PlainTestEntity, to persistence: Persistence) {
        XCTAssertNotNil(try? persistence.save(object: object).toBlocking().first())
    }
    
    func saveObjects(_ objects: [PlainTestEntity], to persistence: Persistence) {
        XCTAssertNotNil(try? persistence.save(objects: objects).toBlocking().first())
    }
}
