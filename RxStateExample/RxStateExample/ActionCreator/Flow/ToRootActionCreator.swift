//
//  ToRootActionCreator.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxSwift
import RxCocoa
import RxState

class ToRootActionCreator {
    struct Inputs {
        let store: StoreType
        let window: UIWindow
    }
    
    // For flow action creators. You need to make sure this Driver completes after emitting one and only one `Action`. This way the subscription gets disposed once it's done (You can't add it to a view controller dispose bag since it would be disposed once the transision completes and just before the `transissionedToRoute` is dispatched.
    static func create(inputs: ToRootActionCreator.Inputs) -> Driver<ActionType> {
        
        let destinationRoute = Route.root
        
        // Any better way to make this 
        return inputs.store.flowState
            .flatMapLatest { (flowState: FlowStateManager.State) -> Driver<(Route?, Route, NavigatableController)> in
                return Driver.of((flowState.currentRoute, destinationRoute, flowState.currentRouteNavigatableController))
            }
            .asObservable()
            .take(1)
            .flatMap { (originRoute: Route?, destinationRoute: Route, navigatableController: NavigatableController) -> Observable<ActionType> in
                return ToRootActionCreator.transission(fromRoute: originRoute, toRoute: destinationRoute, usingNavigatableController: navigatableController, inputs: inputs).asObservable()
            }
            .asDriver(onErrorJustReturn: FlowStateManager.Action.transissionToRoute(route: Route.root)) // The Observable being converted doesn't emmit errors. Hence, this won't be returned
    }
    
    private static func transission(fromRoute originRoute: Route?, toRoute destinationRoute: Route, usingNavigatableController navigatableController: NavigatableController, inputs: ToRootActionCreator.Inputs) -> Driver<ActionType> {
        
        guard case (nil, Route.root) = (originRoute, destinationRoute) else {
            fatalError("Using wrong dispatcher or the path is not supported")
        }
        
        let result: Driver<ActionType> = Observable.create { (observer: AnyObserver<ActionType>) -> Disposable in
            observer.on(.next(FlowStateManager.Action.transissionToRoute(route: destinationRoute)))
            let navigationController = NavigationController()
            inputs.window.rootViewController = navigationController
            
            let navigatableController = NavigatableController(
                viewController: navigatableController.viewController
                , navigationController: navigationController
                , tabBarController: navigatableController.tabBarController
            )
            
            let action: ActionType = FlowStateManager.Action.transissionedToRoute(route: destinationRoute, currentRouteNavigatableController: navigatableController)
            
            observer.on(.next(action))
            observer.on(.completed)

            return Disposables.create()
        }
        .asDriver(onErrorJustReturn: FlowStateManager.Action.transissionToRoute(route: Route.root)) // The Observable being converted doesn't emmit errors. Hence, this won't be returned
        
        return result
    }
}
