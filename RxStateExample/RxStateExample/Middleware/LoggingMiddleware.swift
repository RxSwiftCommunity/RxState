//
//  LoggingMiddleware.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxSwift
import RxState
import RxCocoa

protocol LoggingMiddlewareType: MiddlewareType, HasDisposeBag {}

final class LoggingMiddleware: LoggingMiddlewareType {
    var disposeBag = DisposeBag()
    
    func observe(store: StoreType) {
        store.currentStateLastAction
            .drive(
                onNext: { (currentState: [SubstateType], lastAction: ActionType?) in
                    print("\n---------------------------------------------")
                    print("\n*************** Current State ***************")
                    print(currentState)
                    print("\n************* Dispatched Action *************")
                    if let lastAction = lastAction {
                        print(lastAction)
                    } else {
                        print("No action has been dispatched yet")
                    }
                    
                    #if TRACE_RESOURCES
                        if case let Store.FlowAction.transissionToRoute(route)? = lastAction {
                            print("Number of resources before transissioning to \(route) = \(Resources.total)")
                        }
                        if case let Store.FlowAction.transissionedToRoute(route, _)? = lastAction {
                            print("Number of resources after transissioning to \(route) = \(Resources.total)")
                            
                        }
                    #endif
                    
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
