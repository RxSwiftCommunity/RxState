//
//  AppDelegate.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import UIKit
import RxCocoa
import RxSwift
import RxState

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    override init() {
        super.init()
        setupMiddlewares()
        setupInitialStates()
    }
    var window: UIWindow?
    
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        window.rootViewController = UIViewController()
        self.window = window
        openApp(onWindow: window)
        
        return true
    }
}

extension AppDelegate {
    func setupInitialStates(){
        let tasksState = Store.TasksState()
        let flowState = Store.FlowState()
        store.dispatch(action: Store.Action.add(subStates: [tasksState, flowState]))
    }
    
    func setupMiddlewares(){
        let loggingService = LoggingMiddleware()
        store.register(middlewares: [loggingService])
    }
    
    func openApp(onWindow window: UIWindow) {
        let navigatetoRootActionCreatorInputs = ToRootCoordinator.Inputs(store: store, window: window)
        
        let navigateRootToTasksActionCreatorInputs = RootToTasksCoordinator.Inputs(store: store)
        
        _ = Driver.concat([
            ToRootCoordinator.navigate(inputs: navigatetoRootActionCreatorInputs)
            , RootToTasksCoordinator.navigate(inputs: navigateRootToTasksActionCreatorInputs)
            ])
            .drive()
    }
}
