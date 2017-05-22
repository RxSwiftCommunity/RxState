//
//  FlowStateManager.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxCocoa
import RxSwift
import CoreLocation
import RxState

final class NavigatableController: CustomDebugStringConvertible {
    weak var viewController: UIViewController?
    weak var navigationController: UINavigationController?
    weak var tabBarController: UITabBarController?
    
    init(
        viewController: UIViewController?
        , navigationController: UINavigationController?
        , tabBarController: UITabBarController?
        ) {
        self.viewController = viewController
        self.navigationController = navigationController
        self.tabBarController = tabBarController
    }
    
    var debugDescription: String {
        return "viewController: \(String(describing: viewController))"
            .appending("\nnavigationController: \(String(describing: navigationController))")
            .appending("\ntabBarController: \(String(describing: tabBarController))")
    }
}

final class FlowStateManager {
    struct State: SubstateType, CustomDebugStringConvertible, Equatable {
        var transissioningToRoute: Route?
        var currentRoute: Route?
        var currentRouteNavigatableController: NavigatableController
        
        init() {
            self.currentRouteNavigatableController = NavigatableController(viewController: nil, navigationController: nil, tabBarController: nil)
        }
        
        static func ==(lhs: FlowStateManager.State, rhs: FlowStateManager.State) -> Bool {
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
    
    enum Action: ActionType, Equatable {
        case transissionToRoute(route: Route)
        case transissionedToRoute(route: Route, currentRouteNavigatableController: NavigatableController)
        
        static func ==(lhs: FlowStateManager.Action, rhs: FlowStateManager.Action) -> Bool {
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
    
    static func reduce(state: FlowStateManager.State, sction: FlowStateManager.Action) -> FlowStateManager.State {
        switch sction {
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
    /// A convenience computed variable to extract `(CoordinatingService.State, CoordinatingService.Action)` from `CurrentStateLastAction`
    var coordinatingServiceCurrentStateLastAction: Driver<(FlowStateManager.State, FlowStateManager.Action)> {
        let coordinatingServiceCurrentStateLastAction = currentStateLastAction
            .flatMap { (states: [SubstateType], lastAction: ActionType?) -> Driver<(FlowStateManager.State, FlowStateManager.Action)> in
                for state in states {
                    guard let coordinatingServiceState = state as? FlowStateManager.State else { continue }
                    guard let coordinatingServiceAction = lastAction as? FlowStateManager.Action else {
                        return Driver.never()
                    }
                    return Driver.just(coordinatingServiceState, coordinatingServiceAction)
                }
                fatalError("You need to register `CoordinatingService.State` first")
            }
            .distinctUntilChanged { (lhs: (FlowStateManager.State, FlowStateManager.Action), rhs: (FlowStateManager.State, FlowStateManager.Action)) -> Bool in
                return lhs.0 == rhs.0 && lhs.1 == rhs.1
        }
        
        return coordinatingServiceCurrentStateLastAction
    }
    
    /// A convenience computed variable to extract `FlowStateManager.State` from the application state
    var flowState: Driver<FlowStateManager.State> {
        let flowState = store.state
            .flatMap { (states: [SubstateType]) -> Driver<FlowStateManager.State> in
                for state in states {
                    guard let value = state as? FlowStateManager.State else { continue }
                    return Driver<FlowStateManager.State>.just(value)
                }
                fatalError("You need to register `FlowStateManager.State` first")
            }
            .distinctUntilChanged()
        
        return flowState
    }
    
    /// A convenience computed variable to extract `FlowStateManager.State.navigatableController` from the application state
    var navigatableController: Driver<NavigatableController> {
        let navigatableController: Driver<NavigatableController> = store.flowState
            .map { (state: FlowStateManager.State) -> NavigatableController in
                return state.currentRouteNavigatableController
        }
        return navigatableController
    }
    
    /// A convenience computed variable to extract `FlowStateManager.State.originRoute` from the application state
    var originRoute: Driver<Route?> {
        let originRoute: Driver<Route?> = store.flowState
            .map { (state: FlowStateManager.State) -> Route? in
                return state.currentRoute
        }
        return originRoute
    }
    
    /// A convenience computed variable to extract `FlowStateManager.State.originRoute` from the application state
    var currentRoute: Driver<Route?> {
        let currentRoute: Driver<Route?> = store.flowState
            .map { (state: FlowStateManager.State) -> Route? in
                return state.currentRoute
        }
        return currentRoute
    }
}
