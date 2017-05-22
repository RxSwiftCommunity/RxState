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
    case let action as TasksStateManager.Action:
        guard var (tasksStateIndex, tasksState) = state.enumerated().first(where: { (_: Int, state: SubstateType) -> Bool in
            let result = state is TasksStateManager.State
            return result
        }) as? (Int, TasksStateManager.State) else {
            fatalError("You need to register `TasksStateManager.State` first")
        }
        
        tasksState = TasksStateManager.reduce(state: tasksState, sction: action)
        
        state[tasksStateIndex] = tasksState as SubstateType
        
    case let action as FlowStateManager.Action:
        guard var (flowStateIndex, flowState) = state.enumerated().first(where: { (_: Int, state: SubstateType) -> Bool in
            let result = state is FlowStateManager.State
            return result
        }) as? (Int, FlowStateManager.State) else {
            fatalError("You need to register `TasksStateManager.State` first")
        }
        
        flowState = FlowStateManager.reduce(state: flowState, sction: action)
        
        state[flowStateIndex] = flowState as SubstateType
        
    default:
        fatalError("Unknown action type")
    }
    
    return state
}
