//
//  FlowActionCreatorType.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxState
import RxSwift
import RxCocoa

/**
 For flow action creators
 
 1- We need to make sure Action Driver created completed. This way the subscription gets disposed once it's done (You can't add it to a view controller dispose bag since it would be disposed once the transision completes and just before the `transissionedToRoute` is dispatched.
 
 2- We can't use the dispose bag of the view/view controller to dispose of `Driver<ActionType>` returned from the `create` function because the subscription should out live the view/view controller that "trigged" them: The `transissionedToRoute` Action should be dispatched after the flow transission is finished -> After the view/view controller triggered the tranission is dinitiated -> After thier dispose bag is emptied.
 
 3- Since by design, a Flow Action Creator always completes and should not be canceled once it started, the `navigate(_)` function should be called to trigger the navigation instead of calling `create(_),  getting the `Driver<ActionType>`, subscribing to it, and dispatching the actions received
 */
protocol FlowActionCreatorType: ActionCreatorType {
    // Perform the navigation and return a `completed` once the navigation is done.
    // Do not subscrib and add the disposable to a dispose bag, the subscription should terminate automatically.
    // The internsion of using a driver here is just to chain navigations. 
    static func navigate(inputs: I) -> Driver<Void>
}

extension FlowActionCreatorType {
    static func navigate(inputs: I) -> Driver<Void> {
        let result: Driver<Void> = create(inputs: inputs)
            .do(onNext: { (action: ActionType) in
                inputs.store.dispatch(action: action)
            }, onCompleted: nil, onSubscribe: nil, onDispose: nil)
            .flatMap{ (_) -> Driver<Void> in
                return Driver.empty()
            }
        
        return result
    }
}
