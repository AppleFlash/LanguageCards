//
//  StateMachineTests.swift
//  LanguageCardsAppTests
//
//  Created by Vladislav Sedinkin on 15.11.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import RxTest

@testable import LanguageCardsApp

private struct TestState: StateType, Equatable {
    enum Action {
        case increment
        case decrement
    }
    
    var value: Int = 0
    
    mutating func reduce(_ action: TestState.Action) {
        switch action {
        case .increment:
            value += 1
        case .decrement:
            value -= 1
        }
    }
}

class StateMachineTests: QuickSpec {
    override func spec() {
        describe("state machine test") {
            context("change states") {
                var store: Store<TestState>!
                var disposeBag: DisposeBag!
                var scheduler: TestScheduler!
                var observer: TestableObserver<TestState>!
                let initialValue = 10
                beforeEach {
                    store = Store(initialState: TestState(value: initialValue), scheduler: MainScheduler.instance)
                    scheduler = .init(initialClock: 0)
                    disposeBag = .init()
                    observer = scheduler.createObserver(TestState.self)
                }
                
                func test(
                    actions: [Recorded<Event<TestState.Action>>],
                    expected: @escaping () -> [Recorded<Event<TestState>>],
                    line: UInt = #line
                ) {
                    store.state
                        .subscribe(observer)
                        .disposed(by: disposeBag)
                    
                    scheduler
                        .createColdObservable(actions)
                        .subscribe(onNext: store.sink)
                        .disposed(by: disposeBag)
                    
                    scheduler.start()
                    
                    expect(observer.events, line: line) == expected()
                }
                
                it("value incremented") {
                    test(
                        actions: [.next(0, .increment)],
                        expected: {
                            [
                                .next(0, TestState(value: initialValue)),
                                .next(0, TestState(value: initialValue + 1))
                            ]
                        }
                    )
                }
                
                it("value decremented") {
                    test(
                        actions: [.next(0, .decrement)],
                        expected: {
                            [
                                .next(0, TestState(value: initialValue)),
                                .next(0, TestState(value: initialValue - 1))
                            ]
                        }
                    )
                }
                
            }
            
        }
    }
}

//func test<T: StateType>(
//    store: Store<T>,
//    observer: TestableObserver<T>,
//    scheduler: TestScheduler,
//    actions: [Recorded<Event<T.Action>>],
//    disposeBag: DisposeBag,
//    expected: @escaping () -> [Recorded<Event<T>>],
//    line: UInt = #line
//) where T: Equatable {
//    store.state
//        .subscribe(observer)
//        .disposed(by: disposeBag)
//
//    scheduler
//        .createColdObservable(actions)
//        .subscribe(onNext: store.sink)
//        .disposed(by: disposeBag)
//
//    scheduler.start()
//
//    expect(observer.events, line: line) == expected()
//}
