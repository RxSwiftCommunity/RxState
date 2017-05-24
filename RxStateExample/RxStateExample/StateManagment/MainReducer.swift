//
//  MainReducer.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxState

let mainReducer: MainReducer = { (state: [SubstateType], action: ActionType) -> [SubstateType] in
    var state: [SubstateType] = state
    switch action {
    case let action as Store.TasksAction:
        guard var (tasksStateIndex, tasksState) = state.enumerated().first(where: { (_: Int, state: SubstateType) -> Bool in
            let result = state is Store.TasksState
            return result
        }) as? (Int, Store.TasksState) else {
            fatalError("You need to register `Store.TasksState` first")
        }
        
        tasksState = Store.reduce(state: tasksState, action: action)
        
        state[tasksStateIndex] = tasksState as SubstateType
        
    case let action as Store.FlowAction:
        guard var (flowStateIndex, flowState) = state.enumerated().first(where: { (_: Int, state: SubstateType) -> Bool in
            let result = state is Store.FlowState
            return result
        }) as? (Int, Store.FlowState) else {
            fatalError("You need to register `Store.TasksState` first")
        }
        
        flowState = Store.reduce(state: flowState, action: action)
        
        state[flowStateIndex] = flowState as SubstateType
        
    default:
        fatalError("Unknown action type")
    }
    
    return state
}
