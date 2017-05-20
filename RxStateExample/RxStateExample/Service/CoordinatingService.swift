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
    //    func transission(toRoute route: Route) -> Observable<CoordinatingService.Action>
}

final class CoordinatingService: CoordinatingServiceType {
    
    fileprivate let store: StoreType
    fileprivate var disposeBag = DisposeBag()
    
    fileprivate weak var _navigatableNavigationController: NavigationController?

    /// A convenience variable to extract `(CoordinatingService.State, CoordinatingService.Action)` from the application `currentStateLastAction`
    var coordinatingServiceStateLastAction: Driver<(CoordinatingService.State, CoordinatingService.Action)> {
        let coordinatingServiceState = store.currentStateLastAction
            .flatMap { (states: [SubstateType], lastAction: ActionType?) -> Driver<(CoordinatingService.State, CoordinatingService.Action)> in
                for state in states {
                    guard let coordinatingServiceState = state as? CoordinatingService.State else { continue }
                    guard let coordinatingServiceAction = lastAction as? CoordinatingService.Action else {
                        return Driver.never()
                    }
                    return Driver.just(coordinatingServiceState, coordinatingServiceAction)
                }
                fatalError("You need to register `CoordinatingService.State` first")
            }
            .distinctUntilChanged { (lhs: (CoordinatingService.State, CoordinatingService.Action), rhs: (CoordinatingService.State, CoordinatingService.Action)) -> Bool in
                return lhs.0 == rhs.0 && lhs.1 == rhs.1
        }
        
        return coordinatingServiceState
    }
    
    init(store: StoreType) {
        self.store = store
    }
    
    func i() {
        coordinatingServiceStateLastAction
            .flatMap { (state: CoordinatingService.State , action: CoordinatingService.Action) -> Driver<(Route?, Route)> in
                
                switch action {
                case .transissionedToRoute(_):
                    return Driver.never()
                case let .transissionToRoute(route):
                    return Driver.of((state.currentRoute, route))
                }
                
            }
            .flatMap { (fromRoute: Route?, toRoute: Route) -> Driver<CoordinatingService.Action> in
                return self.transission(fromRoute: fromRoute, toRoute: toRoute)
            }
            .drive(onNext: { (action: CoordinatingService.Action) in
                self.store.dispatch(action: action)
            }
                , onCompleted: nil
                , onDisposed: nil
            )
            .disposed(by: disposeBag)
        
        coordinatingServiceStateLastAction
            .flatMap { (_, coordinatingServiceLastAction: CoordinatingService.Action) -> Driver<CoordinatingService.Action> in
                if case let CoordinatingService.Action.transissionedToRoute(route) = coordinatingServiceLastAction
                    , case Route.root(_) = route{
                    return Driver.of(CoordinatingService.Action.transissionToRoute(route: Route.tasks))
                } else {
                    return Driver.never()
                }
            }
            .drive(onNext: { (action: CoordinatingService.Action) in
                self.store.dispatch(action: action)
            }, onCompleted: nil, onDisposed: nil
            )
            .disposed(by: disposeBag)
        
    }
    
    // A way to break this down? Anyone?
    fileprivate func transission(fromRoute originRoute: Route?, toRoute destinationRoute: Route) -> Driver<CoordinatingService.Action> {
        
        // Handling the initial route in the switch is possble but it will result in a lot of biolerplate!
        if case let Route.root(window) = destinationRoute {
            let navigationController = NavigationController()
            window.rootViewController = navigationController
            self._navigatableNavigationController = navigationController
            return Driver.of(CoordinatingService.Action.transissionedToRoute(route: destinationRoute))
        }
        
        guard let originRoute = originRoute
            , let navigatableNavigationController = self._navigatableNavigationController else {
                fatalError("No currentRoute found! Have you transotioned to `Route.root(onWindow: UIWindow)`?")
        }
        
        switch (originRoute, destinationRoute) {
            
        case (_, .root):
            fatalError("Already matched, can't happen! ")
            
        case (.task(_), .tasks):
            
            return navigatableNavigationController.rx.popViewController(true)
                .flatMap { (_) -> Driver<CoordinatingService.Action> in
                    Driver.of(CoordinatingService.Action.transissionedToRoute(route: destinationRoute))
            }
            
        case (.root, .tasks):
            let viewModel = TasksViewControllerViewModel(store: self.store, taskProvider: TaskProvider(), coordinatingService: self)
            let viewController = TasksViewController.build(withViewModel: viewModel)
            
            return navigatableNavigationController.rx.pushViewController(viewController, animated: true)
                .flatMap { (_) -> Driver<CoordinatingService.Action> in
                    Driver.of(CoordinatingService.Action.transissionedToRoute(route: destinationRoute))
            }
            
            
        case (_, .tasks):
            fatalError("Unknown path: \(originRoute) -> \(destinationRoute)")
            
        case (.tasks, let .task(id)):
            
            let viewModel = TaskViewControllerViewModel(store: self.store, taskId: id, taskProvider: TaskProvider(), coordinatingService: self)
            let viewController = TaskViewController.build(withViewModel: viewModel)
            viewController.addBackButton()
            viewController.edgesForExtendedLayout = []
            return navigatableNavigationController.rx.pushViewController(viewController, animated: true)
                .flatMap { (_) -> Driver<CoordinatingService.Action> in
                    Driver.of(CoordinatingService.Action.transissionedToRoute(route: destinationRoute))
            }
            
            
        case (_, .task):
            fatalError("Unsupported path: \(originRoute) -> \(destinationRoute)")
        }
    }
}

// State managment
extension CoordinatingService {
    struct State: SubstateType, Equatable {
        var currentRoute: Route
        
        init(window: UIWindow) {
            currentRoute = Route.root(window: window)
        }
        
        static func ==(lhs: CoordinatingService.State, rhs: CoordinatingService.State) -> Bool {
            let result = lhs.currentRoute == rhs.currentRoute
            
            return result
        }
        
        /// A textual representation of this instance, suitable for debugging.
        var debugDescription: String {
            let result = "CoordinatingService.state\n"
                + "currentRoute = \(String(describing: currentRoute))\n"
            
            return result
        }

    }
    
    enum Action: ActionType, Equatable {
        case transissionToRoute(route: Route)
        case transissionedToRoute(route: Route)
        
        static func ==(lhs: CoordinatingService.Action, rhs: CoordinatingService.Action) -> Bool {
            switch (lhs, rhs) {
            case (let .transissionToRoute(lhsRoute), let transissionToRoute(rhsRoute)):
                return lhsRoute == rhsRoute
                
            case (let .transissionedToRoute(lhsRoute), let transissionedToRoute(rhsRoute)):
                return lhsRoute == rhsRoute
                
            default:
                return false
            }
        }
    }
    
    static func reduce(state: CoordinatingService.State, sction: CoordinatingService.Action) -> CoordinatingService.State {
        switch sction {
        case .transissionToRoute(_):
            return state
            
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
