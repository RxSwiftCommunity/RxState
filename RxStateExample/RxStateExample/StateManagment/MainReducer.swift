//
//  MainReducer.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxState

let mainReducer: MainReducer = { (state: [SubstateType], action: ActionType) -> [SubstateType] in
    // Copy the `App State`
    var state: [SubstateType] = state
    switch action {
    // Cast to a spcific `Action`.
    case let action as Store.TasksAction:
        // Extract the `Substate`.
        guard var (tasksStateIndex, tasksState) = state
            .enumerated()
            .first(where: { (_, substate: SubstateType) -> Bool in
                let result: Bool = substate is Store.TasksState
                return result
            }
            ) as? (Int, Store.TasksState)
            else {
                fatalError("You need to register `Store.TasksState` first")
        }
        
        // Reduce the `Substate` to get a new `Substate`.
        tasksState = Store.reduce(state: tasksState, action: action)
        
        // Replace the `Substate` in the `App State` with the new `Substate`.
        state[tasksStateIndex] = tasksState as SubstateType
        
    case let action as Store.FlowAction:
        guard var (flowStateIndex, flowState) = state
            .enumerated()
            .first(where: { (_: Int, state: SubstateType) -> Bool in
                let result: Bool = state is Store.FlowState
                return result
            }) as? (Int, Store.FlowState)
            else {
                fatalError("You need to register `Store.TasksState` first")
        }
        
        flowState = Store.reduce(state: flowState, action: action)
        
        state[flowStateIndex] = flowState as SubstateType
        
    default:
        fatalError("Unknown action type")
    }
    
    // Return the new `App State`
    return state
}
