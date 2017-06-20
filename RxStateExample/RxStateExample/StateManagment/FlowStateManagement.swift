//
//  FlowStateManagement.swift
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
    struct FlowState: SubstateType, CustomDebugStringConvertible, Equatable {
        var transissioningToRoute: Route?
        var currentRoute: Route?
        var currentRouteNavigatableController: NavigatableController
        
        init() {
            self.currentRouteNavigatableController = NavigatableController()
        }
        
        static func ==(lhs: Store.FlowState, rhs: Store.FlowState) -> Bool {
            let result = lhs.currentRoute == rhs.currentRoute
            
            return result
        }
        
        /// A textual representation of this instance, suitable for debugging.
        var debugDescription: String {
            let result = "FlowStateManager.state\n"
                + "currentRoute = \(String(describing: currentRoute))\n"
                + "transissioningToRoute = \(String(describing: transissioningToRoute))\n"
            
            return result
        }
        
    }
    
    enum FlowAction: ActionType, Equatable {
        case transissionToRoute(route: Route)
        case transissionedToRoute(route: Route, currentRouteNavigatableController: NavigatableController)
        
        static func ==(lhs: Store.FlowAction, rhs: Store.FlowAction) -> Bool {
            switch (lhs, rhs) {
            case (let .transissionToRoute(lhsRoute), let transissionToRoute(rhsRoute)):
                return lhsRoute == rhsRoute
                
            case (
                let .transissionedToRoute(lhsRoute, _)
                , let transissionedToRoute(rhsRoute, _)):
                return lhsRoute == rhsRoute
                
            default:
                return false
            }
        }
    }
    
    static func reduce(state: Store.FlowState, action: Store.FlowAction) -> Store.FlowState {
        switch action {
        case let .transissionToRoute(route):
            var state = state
            state.transissioningToRoute = route
            return state
            
        case let .transissionedToRoute(route, currentRouteNavigatableController):
            var state = state
            state.transissioningToRoute = nil
            state.currentRoute = route
            state.currentRouteNavigatableController = currentRouteNavigatableController
            return state
        }
    }
}

// MARK: - Shortcuts
extension StoreType {
    
    /// A convenience computed variable to extract `Store.FlowState` from the application state
    var flowState: Driver<Store.FlowState> {
        let flowState = store.state
            .flatMap { (states: [SubstateType]) -> Driver<Store.FlowState> in
                for state in states {
                    guard let value = state as? Store.FlowState else { continue }
                    return Driver<Store.FlowState>.just(value)
                }
                fatalError("You need to register `Store.FlowState` first")
            }
            .distinctUntilChanged()
        
        return flowState
    }
    
    /// A convenience computed variable to extract `Store.FlowState.navigatableController` from the application state
    var navigatableController: Driver<NavigatableController> {
        let navigatableController: Driver<NavigatableController> = store.flowState
            .map { (state: Store.FlowState) -> NavigatableController in
                return state.currentRouteNavigatableController
        }
        return navigatableController
    }
    
    /// A convenience computed variable to extract `Store.FlowState.originRoute` from the application state
    var originRoute: Driver<Route?> {
        let originRoute: Driver<Route?> = store.flowState
            .map { (state: Store.FlowState) -> Route? in
                return state.currentRoute
        }
        return originRoute
    }
    
    /// A convenience computed variable to extract `Store.FlowState.originRoute` from the application state
    var currentRoute: Driver<Route?> {
        let currentRoute: Driver<Route?> = store.flowState
            .map { (state: Store.FlowState) -> Route? in
                return state.currentRoute
        }
        return currentRoute
    }
}

