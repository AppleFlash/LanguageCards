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
    var persistence: Persistence!
    var disposeBag: DisposeBag = .init()
    
    override func setUp() {
        super.setUp()
        
        disposeBag = .init()
        persistence = CoreDataPersistence(coordinatorType: .inMemory)
    }
    
    func testInsertNewObject() {
        let plain = PlainTestEntity(identifier: UUID().uuidString, name: "plain object")
        
        let insertExpectation = expectation(description: "insert expectation")
        
        persistence.save(plain)
            .subscribe(onSuccess: {
                insertExpectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [insertExpectation], timeout: 1)
    }
    
    func testGetObjects() {
        let plain1 = PlainTestEntity(identifier: UUID().uuidString, name: "plain object")
        let plain2 = PlainTestEntity(identifier: UUID().uuidString, name: "plain object")
        
        XCTAssertNotNil(try? persistence.save(plain1).toBlocking().first())
        XCTAssertNotNil(try? persistence.save(plain2).toBlocking().first())
        
        let predicate = \PlainTestEntity.ManagedType.identifier == plain1.identifier
        let savedObject: BlockingObservable<[PlainTestEntity]> = persistence.get(predicate).toBlocking()
        let plainObjects = try? savedObject.first()?.first
        
        XCTAssertEqual(plain1.identifier, plainObjects?.identifier, "fsdf")
    }
}
