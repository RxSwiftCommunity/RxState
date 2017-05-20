//
//  AppDelegate.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import UIKit
import RxCocoa
import RxSwift
import RxState

let mainReducer: MainReducer = { (state: [SubstateType], action: ActionType) -> [SubstateType] in
    var state = state
    switch action {
    case let action as TaskProvider.Action:
        guard var (taskProviderStateIndex, taskProviderState) = state.enumerated().first(where: { (_: Int, state: SubstateType) -> Bool in
            state is TaskProvider.State
        }) as? (Int, TaskProvider.State) else {
            fatalError("You need to register `TaskProvider.State` first")
        }
        
        taskProviderState = TaskProvider.reduce(state: taskProviderState, sction: action)
        
        state[taskProviderStateIndex] = taskProviderState as SubstateType
        
    case let action as CoordinatingService.Action:
        guard var (coordinatingServiceStateIndex, coordinatingServiceState) = state.enumerated().first(where: { (_: Int, state: SubstateType) -> Bool in
            state is CoordinatingService.State
        }) as? (Int, CoordinatingService.State) else {
            fatalError("You need to register `TaskProvider.State` first")
        }
        
        coordinatingServiceState = CoordinatingService.reduce(state: coordinatingServiceState, sction: action)
        
        state[coordinatingServiceStateIndex] = coordinatingServiceState as SubstateType
        
    default:
        fatalError("Unknown action type")
    }
    
    return state
}

let store = Store(mainReducer: mainReducer)

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _: UIApplication
        , didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {
        
        setupInitialStates()
        setupMiddlewares()


        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        window.rootViewController = UIViewController()
        self.window = window
        openApp(onWindow: window)
        
        return true
    }
    
    private func setupInitialStates(){
        let taskProviderState = TaskProvider.State()
        let coordinatingServiceState = CoordinatingService.State()
        store.dispatch(action: Store.Action.add(states: [taskProviderState, coordinatingServiceState]))
    }
    
    private func setupMiddlewares(){
        let coordinatingService = CoordinatingService()
        let loggingService = LoggingService()
        store.register(middlewares: [loggingService, coordinatingService])
    }
    
    private func openApp(onWindow window: UIWindow) {
        _ = store.currentStateLastAction
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
            .filter { (coordinatingServiceState: CoordinatingService.State, _) -> Bool in
                guard let currentRoute = coordinatingServiceState.currentRoute
                    , case Route.root(_) = currentRoute else { return false }
                return true
            }
            .asObservable()
            .take(1)
            .subscribe(onNext: { (_) in
                store.dispatch(action: CoordinatingService.Action.transissionToRoute(route: Route.tasks))
            }, onCompleted: nil, onDisposed: nil)
        
        store.dispatch(action: CoordinatingService.Action.transissionToRoute(route: Route.root(window: window)))
    }
}

