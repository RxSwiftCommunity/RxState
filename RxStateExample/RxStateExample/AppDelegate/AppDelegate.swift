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

#if os(iOS)
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
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
}
#elseif os(macOS)

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
    
#endif

extension AppDelegate {
    fileprivate func setupInitialStates(){
        let tasksState = Store.TasksState()
        let flowState = Store.FlowState()
        store.dispatch(action: Store.Action.add(states: [tasksState, flowState]))
    }
    
    fileprivate func setupMiddlewares(){
        let loggingService = LoggingMiddleware()
        store.register(middlewares: [loggingService])
    }
    
    fileprivate func openApp(onWindow window: UIWindow) {
        let navigatetoRootActionCreatorInputs = ToRootCoordinator.Inputs(store: store, window: window)
        
        let navigateRootToTasksActionCreatorInputs = RootToTasksCoordinator.Inputs(store: store)
        
        _ = Driver.concat([
            ToRootCoordinator.navigate(inputs: navigatetoRootActionCreatorInputs)
            , RootToTasksCoordinator.navigate(inputs: navigateRootToTasksActionCreatorInputs)
            ])
            .drive()
    }
}
