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
     A Driver emmitting a representation of the application state.
     The application state is an array of substates.
     To add substates to the application state, dispatch `Store.Action.register(states: [StateType])`.
     */
    var state: Driver<[SubstateType]> { get }

    /**
     The last dispatched action.
     If the value is `nil`, it means that no Action has been dispatched yet.
     */
    var action: Driver<ActionType?> { get }

    /**
     The last dispatched action with the resulted state.
     */
    var currentStateLastAction: Driver<CurrentStateLastAction> { get }

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

    public var currentStateLastAction: Driver<CurrentStateLastAction> {
        return Driver.zip(
            state
            , action
        ) { (currentState: [SubstateType], action: ActionType?) -> CurrentStateLastAction in
            CurrentStateLastAction(currentState, action)
        }
    }

    public var state: Driver<[SubstateType]> {
        return _state.asDriver()
    }
    
    public var middlewares: [MiddlewareType] = []

    private let _state: Variable<[SubstateType]> = Variable([SubstateType]())

    
    public var action: Driver<ActionType?> {
        return _action.asDriver()
    }
    private let _action: Variable<ActionType?> = Variable(nil)

    public func dispatch(action: ActionType) {
        _action.value = action
        if let storeAction = action as? Store.StoreAction {
            _state.value = Store.reduce(state: _state.value, sction: storeAction)
        } else {
            _state.value = mainReducer(_state.value, action)
        }
    }
    
    public func register(middlewares: [MiddlewareType]) {
        self.middlewares.append(contentsOf: middlewares)

        for middleware in middlewares {
            middleware.observe(store: self)
        }
    }
}

extension Store {
    public enum StoreAction: ActionType {
        /// Adds substates to the application state.
        case add(states: [SubstateType])
        
        /// Removes all substates in the application state.
        case reset
    }

    public static func reduce(state: [SubstateType], sction: Store.StoreAction) -> [SubstateType] {
        switch sction {
        case let .add(states):
            var state = state
            state.append(contentsOf: states as [SubstateType])
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
public typealias MainReducer = ((_ state: [SubstateType], _ action: ActionType) -> [SubstateType])

/// A tuple representing the current application state and the last dispatched action.
public typealias CurrentStateLastAction = (currentState: [SubstateType], lastAction: ActionType?)
