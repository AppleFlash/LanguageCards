//
//  GetTests.swift
//  LanguageCardsAppTests
//
//  Created by Vladislav Sedinkin on 20.10.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import XCTest
import RxBlocking
import RxSwift
@testable import LanguageCardsApp

class GetTests: XCTestCase {
    private var networking: BaseNetworking!
    
    override func setUp() {
        super.setUp()
        
        networking = BaseNetworking()
    }
    
    func testGetTranslation() {
        let url = URL(string: "https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20190929T163234Z.d7b2088da6847453.098f158d146176c55ad8a9bafb9a3b0f9aa6091d&text=hello&lang=en-ru")!
        
        typealias ReturnResult = Single<BaseNetworking.NetworkResult<RawTranslation, YandexError>>
        let singleResult: ReturnResult = networking!.perform(url: url)
        let result = try! XCTUnwrap(try? singleResult.toBlocking().first())
    
        XCTAssertNoThrow(try result.get())
    }
    
    func testGetDictionary() {
        let url = URL(string: "https://dictionary.yandex.net/api/v1/dicservice.json/lookup?lang=en-ru&key=dict.1.1.20190929T165134Z.87810b5f7c1e7596.4701a6899643bd992b9c94ec4b9501ffe66e30ee&text=time")!

            typealias ReturnResult = Single<BaseNetworking.NetworkResult<RawDictionaryResponse, YandexError>>
            let singleResult: ReturnResult = networking!.perform(url: url)
            let result = try! XCTUnwrap(try? singleResult.toBlocking().first())

            XCTAssertNoThrow(try result.get())
    }
}
