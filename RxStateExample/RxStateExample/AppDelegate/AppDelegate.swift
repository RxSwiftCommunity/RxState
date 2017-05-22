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
        let tasksState = TasksStateManager.State()
        let flowState = FlowStateManager.State()
        store.dispatch(action: Store.Action.add(states: [tasksState, flowState]))
    }
    
    private func setupMiddlewares(){
        let loggingService = LoggingService()
        store.register(middlewares: [loggingService])
    }
    
    private func openApp(onWindow window: UIWindow) {
        let toRootActionCreatorInputs = ToRootActionCreator.Inputs(store: store, window: window)
        let toRootActionCreator = ToRootActionCreator.create(inputs: toRootActionCreatorInputs)

        let rootToTasksActionCreatorInputs = RootToTasksActionCreator.Inputs(store: store)
        let rootToTasksActionCreator = RootToTasksActionCreator.create(inputs: rootToTasksActionCreatorInputs)

        _ = Driver.concat([toRootActionCreator, rootToTasksActionCreator])
            .drive(onNext: { (action: ActionType) in
                store.dispatch(action: action)
            }, onCompleted: nil, onDisposed: nil)
    }
}

