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
        let tasksState = Store.TasksState()
        let flowState = Store.FlowState()
        store.dispatch(action: Store.Action.add(states: [tasksState, flowState]))
    }
    
    private func setupMiddlewares(){
        let loggingService = LoggingService()
        store.register(middlewares: [loggingService])
    }
    
    private func openApp(onWindow window: UIWindow) {
        let navigatetoRootActionCreatorInputs = NavigateToRootActionCreator.Inputs(store: store, window: window)

        let navigateRootToTasksActionCreatorInputs = NavigateRootToTasksActionCreator.Inputs(store: store)

        _ = Driver.concat([
            NavigateToRootActionCreator.navigate(inputs: navigatetoRootActionCreatorInputs)
            , NavigateRootToTasksActionCreator.navigate(inputs: navigateRootToTasksActionCreatorInputs)
            ])
            .drive()
    }
}

