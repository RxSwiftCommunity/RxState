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
     The last dispatched action with the resulted state.
     */
    var stateLastAction: Driver<StateLastAction> { get }

    /**
     A Driver of `StoreState`.
     To add substates to `StoreState`, dispatch `Store.Action.register(subStates: [SubstateType])`.
     */
    var state: Driver<StoreState> { get }
    
    /**
     A Driver of the last dispatched action.
     If the value is `nil`, it means that no Action has been dispatched yet.
     */
    var lastDispatchedaAtion: Driver<ActionType?> { get }
    
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
    
    public var stateLastAction: Driver<StateLastAction> {
        return Driver.zip(
            state
            , lastDispatchedaAtion
        ) { (state: [SubstateType], lastDispatchedaAtion: ActionType?) -> StateLastAction in
            StateLastAction(state, lastDispatchedaAtion)
        }
    }
    
    public var state: Driver<[SubstateType]> {
        return _state.asDriver()
    }
    
    public var middlewares: [MiddlewareType] = []
    
    private let _state: Variable<StoreState> = Variable(StoreState())
    
    public var lastDispatchedaAtion: Driver<ActionType?> {
        return _lastDispatchedaAtion.asDriver()
    }
    private let _lastDispatchedaAtion: Variable<ActionType?> = Variable(nil)
    
    public func dispatch(action: ActionType) {
        if let storeAction = action as? Store.Action {
            _state.value = Store.reduce(state: _state.value, action: storeAction)
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
    
    public static func reduce(state: StoreState, action: Store.Action) -> StoreState {
        switch action {
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

/// A tuple representing the current application state and the last dispatched action.
public typealias StateLastAction = (currentState: [SubstateType], lastAction: ActionType?)
