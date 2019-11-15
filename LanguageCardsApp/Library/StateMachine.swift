//
//  StateMachine.swift
//  LanguageCardsApp
//
//  Created by Vladislav Sedinkin on 15.11.2019.
//  Copyright © 2019 Vladislav Sedinkin. All rights reserved.
//

import RxSwift

protocol EmptyInitializable {
    init()
}

protocol StateType: EmptyInitializable {
    associatedtype Action
    
    mutating func reduce(_ action: Action)
}

private typealias Reducer<T: StateType> = (inout T, T.Action) -> Void
typealias Feedback<T: StateType> = (Observable<T>) -> Observable<T.Action>

final class Store<T: StateType> {
    private let reducer: Reducer<T>
    private let stateObservable: Observable<T>
    private let actionSubject: PublishSubject<T.Action> = .init()
    
    init(initialState: T = T(), scheduler: SchedulerType) {
        self.reducer = { state, action in
            state.reduce(action)
        }
        
        self.stateObservable = actionSubject
            .observeOn(scheduler)
            .scan(into: initialState, accumulator: self.reducer)
            .startWith(initialState)
    }
    
    var state: Observable<T> { stateObservable }
    
    func sink(action: T.Action) {
        actionSubject.onNext(action)
    }
    
    func sink() -> (T.Action) -> Void {
        return { [actionSubject] action in
            actionSubject.onNext(action)
        }
    }
}
