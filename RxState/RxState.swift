//
//  RxState.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxCocoa
import RxSwift

// SubstateType
public protocol SubstateType {}


/**
 Has the following responsibilities:
 1. Holds application state. It can be access via `state` Driver.
 2. Allows state to be updated via `dispatch<T: ActionType>(action: T)`.
 3. Allows access to the application state and last dipached action via `currentStateLastAction` Driver (Useful for creating middlewere).
 */
public protocol StoreType {

    /// Inisiate the store with a main reducer that the dispatch method will use to reduce incomming actions
    init(mainReducer: @escaping MainReducer)

    /**
     A Hot Observables of `StoreState`.
     To add substates to `StoreState`, dispatch `Store.Action.register(subStates: [SubstateType])`.
     */
    var state: Observable<StoreState> { get }

    /**
     A Hot Observables of the last dispatched action.
     If the value is `nil`, it means that no Action has been dispatched yet.
     */
    var lastDispatchedaAtion: Observable<ActionType?> { get }

    /**
     Dispatches a action, causing the `state` to be updated.
     
     - parameters action: The action to be dispatched.
     
     */
    func dispatch(action: ActionType)
    
    
    /**
     Registers middlewares.
     
     - parameters middlewares: An array containg the middlewares to be registered.
     
     */
    func register(middlewares: [MiddlewareType])

}


public class Store: StoreType {

    fileprivate let mainReducer: MainReducer

    required public init(mainReducer: @escaping MainReducer) {
        self.mainReducer = mainReducer
    }

    public var state: Observable<[SubstateType]> {
        return _state.asObservable().share(replay: 1, scope: SubjectLifetimeScope.forever)
    }
    
    public var middlewares: [MiddlewareType] = []

    private let _state: Variable<StoreState> = Variable(StoreState())

    public var lastDispatchedaAtion: Observable<ActionType?> {
        return _lastDispatchedaAtion.asObservable().share(replay: 1, scope: SubjectLifetimeScope.forever)
    }
    private let _lastDispatchedaAtion: Variable<ActionType?> = Variable(nil)

    public func dispatch(action: ActionType) {
        if let storeAction = action as? Store.Action {
            _state.value = Store.reduce(state: _state.value, sction: storeAction)
        } else {
            _state.value = mainReducer(_state.value, action)
        }
        _lastDispatchedaAtion.value = action
    }
    
    public func register(middlewares: [MiddlewareType]) {
        self.middlewares.append(contentsOf: middlewares)

        for middleware in middlewares {
            middleware.observe(store: self)
        }
    }
}

extension Store {
    public enum Action: ActionType {
        /// Adds substates to the store's state.
        case add(subStates: [SubstateType])
        
        /// Removes all substates in the store's state.
        case reset
    }

    public static func reduce(state: StoreState, sction: Store.Action) -> StoreState {
        switch sction {
        case let .add(states):
            var state = state
            state.append(contentsOf: states as StoreState)
            return state
        case .reset:
            return []
        }
    }
}

/**
 Data structure that describe intended state changes.
 You should define actions for every possible state change that can happen.
 State change can only happen only by dispatching Action.
 That's how you get predictable state change.
 */
public protocol ActionType {}

/**
 Data structure that describe intended state changes.
 You should define actions for every possible state change that can happen.
 State change can only happen only by dispatching Action.
 That's how you get predictable state change.
 */
public protocol MiddlewareType {
    func observe(store: StoreType)
}

/**
 This reducer is used by the store's dispatch function. It should call the respective reducer basied on the Action type.
 */
public typealias MainReducer = ((_ state: StoreState, _ action: ActionType) -> StoreState)


/**
 This reducer is used by the store's dispatch function. It should call the respective reducer basied on the Action type.
 */
public typealias StoreState = [SubstateType]
