//
//  RxStateExampleTests.swift
//  RxStateExampleTests
//
//  Created by Nazih on 02/06/2017.
//  Copyright © 2017 RxState. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import Foundation
import RxState

class RxStateExampleTests: XCTestCase {
    
    let store: Store = Store(mainReducer: mainReducer)
    
    func setupInitialStates(){
        let tasksState = Store.TasksState()
        let flowState = Store.FlowState()
        store.dispatch(action: Store.StoreAction.add(states: [tasksState, flowState]))
    }
    
    func setupMiddlewares(){
        let loggingService = LoggingMiddleware()
        store.register(middlewares: [loggingService])
    }

    override func setUp() {
        super.setUp()
        setupMiddlewares()
        setupInitialStates()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_SummaryTransformer() {
        // Prepare
        let task = Task(summary: "TestSummary0", status: TaskStatus.done)
        store.dispatch(action: Store.TasksAction.addTask(task: task))

//        let summaryTransformerInputs = SummaryTransformer.Inputs(store: store, taskId: task.id)
//        let summaryTransformerOutputs = SummaryTransformer.transtorm(inputs: summaryTransformerInputs)
    }
    
}
