//
//  ErrorStateManagment.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxCocoa
import RxSwift
import CoreLocation
import RxState

extension Store {
    struct ErrorState: SubstateType, CustomDebugStringConvertible {
        var silentError: Error?
        var presentableError: Error?
        
        /// A textual representation of this instance, suitable for debugging.
        var debugDescription: String {
            let result = "ErrorStateManager.state\n"
                .appending("silentError = \(String(describing: silentError.debugDescription))\n")
                .appending("presentableError = \(String(describing: presentableError.debugDescription))\n")
            return result
        }
    }
    
    enum ErrorAction: ActionType {
        case clearErrors
        case addPresentError(presentableError: Error)
        case addSilentError(silentError: Error)
    }
    
    static func reduce(state: Store.ErrorState, action: Store.ErrorAction) -> Store.ErrorState {
        switch action {
        case let .addPresentError(error):
            var state = state
            state.presentableError = error
            return state
            
        case let .addSilentError(error):
            var state = state
            state.silentError = error
            return state
            
        case .clearErrors:
            var state = state
            state.silentError = nil
            state.presentableError = nil
            return state
        }
    }
}

// MARK: - Shortcuts
extension StoreType {
    
    /// A convenience variable to extract `Store.TasksState` from the application state
    var presentableError: Driver<Error> {
        let presentableError = store.state
            .flatMap { (states: [SubstateType]) -> Driver<Error> in
                
                guard let errorStateManagerState = states
                    .first(where: { (state: SubstateType) -> Bool in
                        state is Store.ErrorState
                    }) as? Store.ErrorState
                    else {
                    fatalError("You need to register `Store.TasksState` first")
                }
                
                guard let presentableError = errorStateManagerState.presentableError
                    else {
                    return Driver.never()
                }
                
                return Driver.of(presentableError)
            }
        
        return presentableError
    }
}
