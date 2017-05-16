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
    case let action as Store.Action:
        state = Store.reduce(state: state, sction: action)

    case let action as TaskProvider.Action:
        guard var (taskProviderStateIndex, taskProviderState) = state.enumerated().first(where: { (_: Int, state: SubstateType) -> Bool in
            state is TaskProvider.State
        }) as? (Int, TaskProvider.State) else {
            fatalError("You need to register `TaskProvider.State` first")
        }

        taskProviderState = TaskProvider.reduce(state: taskProviderState, sction: action)

        state[taskProviderStateIndex] = taskProviderState as SubstateType

    default:
        fatalError("Unknown action type")
    }

    return state
}

let store = Store(mainReducer: mainReducer)
let loggingService = LoggingService(store: store)

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _: UIApplication
        , didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        window.makeKeyAndVisible()

        loggingService.startLoggingAppState()

        let taskProviderState = TaskProvider.State()
        store.dispatch(action: Store.Action.register(states: [taskProviderState]))

        let tasksViewControllerViewModel = TasksViewControllerViewModel(taskProvider: TaskProvider())
        let tasksViewController = TasksViewController.build(withViewModel: tasksViewControllerViewModel)
        let navigationController = NavigationController(rootViewController: tasksViewController)

        window.rootViewController = navigationController

        self.window = window
        return true
    }
}
