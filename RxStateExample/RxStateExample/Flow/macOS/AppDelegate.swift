//
//  AppDelegate.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Cocoa
import RxState

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    override init() {
        super.init()
        setupMiddlewares()
        setupInitialStates()
    }
    
    func applicationDidFinishLaunching(aNotification: Notification) {
    }
    
    func applicationWillTerminate(aNotification: Notification) {
    }
}

extension AppDelegate {
    func setupInitialStates(){
        let tasksState = Store.TasksState()
        let flowState = Store.FlowState()
        store.dispatch(action: Store.StoreAction.add(states: [tasksState, flowState]))
    }
    
    func setupMiddlewares() {
        let loggingService = LoggingMiddleware()
        store.register(middlewares: [loggingService])
    }
}
