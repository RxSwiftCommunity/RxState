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
let loggingService = LoggingService(store: store)
let coordinatingService = CoordinatingService()

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _: UIApplication
        , didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        window.rootViewController = UIViewController()
        self.window = window

        loggingService.startLoggingAppState()

        let taskProviderState = TaskProvider.State()
        let coordinatingServiceState = CoordinatingService.State()
        store.dispatch(action: Store.Action.register(states: [taskProviderState, coordinatingServiceState]))

        _ = coordinatingService.transission(toRoute: Route.root(window: window))
            .concat(coordinatingService.transission(toRoute: Route.tasks)) // Once the root route is up, go to tasks route
            .subscribe(onNext: { (action: CoordinatingService.Action) in
                store.dispatch(action: action)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
        
        
        return true
    }
}
