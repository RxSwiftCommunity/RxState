//
//  FlowCoordinatorType.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxState
import RxSwift
import RxCocoa

/**
Flow Coordinator is an Action Creator. However, Flow Coordinator can dispatchers the Actions it generate itself instead of delevering them to the View Model using the Mixin function `navigate(_)` which retunes a `Driver<Void>` that only sends `.completed`.
 
 Notes:
    1- Make sure `Driver<Action>` returned by the `create(_)` function always completes.
 
    2- We can't use the dispose bag of the view/view controller to dispose of `Driver<ActionType>` returned from the `create(_)` function because the subscription should out live the view/view controller that "trigged" them: The `transissionedToRoute` Action should be dispatched after the flow transission is finished -> After the view/view controller triggered the tranission is dinitiated -> After thier dispose bag is emptied.
 */
protocol FlowCoordinatorType: ActionCreatorType {
    // Perform the navigation and return a `completed` once the navigation is done.
    // Do not subscrib and add the disposable to a dispose bag, the subscription should terminate automatically.
    // The internsion of using a driver here is just to chain navigations. 
    static func navigate(inputs: I) -> Driver<Void>
}

extension FlowCoordinatorType {
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
