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

protocol CoordinatingServiceType: Middleware, HasDisposeBag {}

final class CoordinatingService: CoordinatingServiceType {
    
    var disposeBag = DisposeBag()
    fileprivate weak var navigatableNavigationController: NavigationController!

    func observe(currentStateLastAction: Driver<CurrentStateLastAction>) {
        currentStateLastAction
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
                store.dispatch(action: action)
            }
                , onCompleted: nil
                , onDisposed: nil
            )
            .disposed(by: disposeBag)
    }
    
    // A way to break this down? Anyone?
    fileprivate func transission(fromRoute originRoute: Route?, toRoute destinationRoute: Route) -> Driver<CoordinatingService.Action> {
        
        switch (originRoute, destinationRoute) {
            
        case (nil, let .root(window)):
            let navigationController = NavigationController()
            window.rootViewController = navigationController
            self.navigatableNavigationController = navigationController
            return Driver.of(CoordinatingService.Action.transissionedToRoute(route: destinationRoute))
            
        case (.task?, .tasks):
            
            return navigatableNavigationController.rx.popViewController(true)
                .flatMap { (_) -> Driver<CoordinatingService.Action> in
                    Driver.of(CoordinatingService.Action.transissionedToRoute(route: destinationRoute))
            }

        case (.root?, .tasks):
            let viewModel = TasksViewControllerViewModel(store: store, taskProvider: TaskProvider(), coordinatingService: self)
            let viewController = TasksViewController.build(withViewModel: viewModel)
            
            return navigatableNavigationController.rx.pushViewController(viewController, animated: true)
                .flatMap { (_) -> Driver<CoordinatingService.Action> in
                    Driver.of(CoordinatingService.Action.transissionedToRoute(route: destinationRoute))
            }
            
            
        case (.tasks?, let .task(id)):
            
            let viewModel = TaskViewControllerViewModel(store: store, taskId: id, taskProvider: TaskProvider(), coordinatingService: self)
            let viewController = TaskViewController.build(withViewModel: viewModel)
            viewController.addBackButton()
            viewController.edgesForExtendedLayout = []
            return navigatableNavigationController.rx.pushViewController(viewController, animated: true)
                .flatMap { (_) -> Driver<CoordinatingService.Action> in
                    Driver.of(CoordinatingService.Action.transissionedToRoute(route: destinationRoute))
            }
           
        case (_, .task):
            fatalError("Unsupported path: \(String(describing: originRoute)) -> \(destinationRoute)")
            
        case (_, .root):
            fatalError("Unsupported path: \(String(describing: originRoute)) -> \(destinationRoute)")
            
        case (_, .tasks):
            fatalError("Unknown path: \(String(describing: originRoute)) -> \(destinationRoute)")
        }
        
    }
}

// State managment
extension CoordinatingService {
    struct State: SubstateType, Equatable {
        var currentRoute: Route?
        
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
