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
            )
            else {
                fatalError("You need to register `Store.TasksState` first")
        }
        
        if let verifiedTaskState = tasksState as? Store.TasksState {
            // Reduce the `Substate` to get a new `Substate`.
            tasksState = Store.reduce(state: verifiedTaskState, action: action)
            
            // Replace the `Substate` in the `App State` with the new `Substate`.
            state[tasksStateIndex] = tasksState as SubstateType
        }
        
    case let action as Store.FlowAction:
        guard var (flowStateIndex, flowState) = state
            .enumerated()
            .first(where: { (_: Int, state: SubstateType) -> Bool in
                let result: Bool = state is Store.FlowState
                return result
            })
            else {
                fatalError("You need to register `Store.TasksState` first")
        }
        
        if let verifiedFlowState = flowState as? Store.FlowState {
            flowState = Store.reduce(state: verifiedFlowState, action: action)
            
            state[flowStateIndex] = flowState as SubstateType
        }
        
    default:
        fatalError("Unknown action type")
    }
    
    // Return the new `App State`
    return state
}
