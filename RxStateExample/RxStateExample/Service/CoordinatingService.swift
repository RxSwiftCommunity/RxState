//
//  CoordinatingService.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxState

protocol CoordinatingServiceType {
    func transission(toRoute route: Route) -> Observable<CoordinatingService.Action>
}

final class CoordinatingService: CoordinatingServiceType {
    
    fileprivate weak var _navigatableNavigationController: NavigationController?

    /// A convenience variable to extract `CoordinatingService.State` from the application state
    var coordinatingServiceState: Driver<CoordinatingService.State> {
        let coordinatingServiceState = store.state
            .flatMap { (states: [SubstateType]) -> Driver<CoordinatingService.State> in
                for state in states {
                    guard let value = state as? CoordinatingService.State else { continue }
                    return Driver<CoordinatingService.State>.just(value)
                }
                fatalError("You need to register `TaskProvider.State` first")
            }
            .distinctUntilChanged()
        
        return coordinatingServiceState
    }
    
    // A way to break this down? Anyone?
    func transission(toRoute destinationRoute: Route) -> Observable<CoordinatingService.Action> {
        
        let result = coordinatingServiceState
            .asObservable()
            .take(1)
            .flatMap { [unowned self] (coordinatingServiceState: CoordinatingService.State) -> Observable<CoordinatingService.Action> in
                
                // Handling the initial route in the switch is possble but it will result in a lot of biolerplate!

                if case let Route.root(window) = destinationRoute {
                    let navigationController = NavigationController()
                    window.rootViewController = navigationController
                    self._navigatableNavigationController = navigationController
                    return Observable.of(CoordinatingService.Action.transissionedToRoute(route: destinationRoute))
                }
                
                guard let currentRoute = coordinatingServiceState.currentRoute
                    , let navigatableNavigationController = self._navigatableNavigationController else {
                    fatalError("No currentRoute found! Have you transotioned to `Route.root(onWindow: UIWindow)`?")
                }

                switch (currentRoute, destinationRoute) {
                    
                case (_, .root):
                    fatalError("Already matched, can't happen! ")
                    
                case (.task(_), .tasks):
                    
                    return navigatableNavigationController.rx.popViewController(true)
                        .flatMap { (_) -> Observable<CoordinatingService.Action> in
                            Observable.of(CoordinatingService.Action.transissionedToRoute(route: destinationRoute))
                    }
                    
                case (.root, .tasks):
                    let viewModel = TasksViewControllerViewModel(store: store, taskProvider: TaskProvider(), coordinatingService: self)
                    let viewController = TasksViewController.build(withViewModel: viewModel)
                    
                    return navigatableNavigationController.rx.pushViewController(viewController, animated: true)
                        .flatMap { (_) -> Observable<CoordinatingService.Action> in
                            Observable.of(CoordinatingService.Action.transissionedToRoute(route: destinationRoute))
                    }
                    

                case (_, .tasks):
                    fatalError("Unknown path: \(currentRoute) -> \(destinationRoute)")

                case (.tasks, let .task(id)):
                    
                    let viewModel = TaskViewControllerViewModel(store: store, taskId: id, taskProvider: TaskProvider(), coordinatingService: self)
                    let viewController = TaskViewController.build(withViewModel: viewModel)
                    viewController.addBackButton()
                    viewController.edgesForExtendedLayout = []
                    return navigatableNavigationController.rx.pushViewController(viewController, animated: true)
                        .flatMap { (_) -> Observable<CoordinatingService.Action> in
                            Observable.of(CoordinatingService.Action.transissionedToRoute(route: destinationRoute))
                    }


                case (_, .task):
                    fatalError("Unsupported path: \(currentRoute) -> \(destinationRoute)")
                }
            }

        return result
    }
}

// State managment
extension CoordinatingService {
    struct State: SubstateType, Equatable {
        /// A textual representation of this instance, suitable for debugging.
        var debugDescription: String {
            let result = "CoordinatingService.state\n"
                + "currentRoute = \(String(describing: currentRoute))\n"
            
            return result
        }
        
        var currentRoute: Route?
        
        static func ==(lhs: CoordinatingService.State, rhs: CoordinatingService.State) -> Bool {
            let result = lhs.currentRoute == rhs.currentRoute
            
            return result
        }
    }
    
    enum Action: ActionType {
        case transissionedToRoute(route: Route)
    }
    
    static func reduce(state: CoordinatingService.State, sction: CoordinatingService.Action) -> CoordinatingService.State {
        switch sction {
        case let .transissionedToRoute(route):
            var state = state
            state.currentRoute = route
            return state
        }
    }
}

enum Route: Equatable {
    case root(window: UIWindow)
    case tasks
    case task(id: String)
    
    static func ==(lhs: Route, rhs: Route) -> Bool {
        switch (lhs, rhs) {
        case (let .root(lhsWindow), let root(rhsWindow)):
            return lhsWindow == rhsWindow
            
        case (let .task(lhsId), let task(rhsId)):
            return lhsId == rhsId
            
        case (.tasks, .tasks):
            return true
            
        default:
            return false
        }
    }
}
