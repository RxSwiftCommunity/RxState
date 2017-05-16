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

final class NavigateToRootActionCreator: FlowActionCreatorType {
    struct Inputs: ActionCreatorInputsType {
        let store: StoreType
        let window: UIWindow
    }
    
    static func create(inputs: NavigateToRootActionCreator.Inputs) -> Driver<ActionType> {
        
        let destinationRoute = Route.root
        
        // Any better way to make this 
        return inputs.store.flowState
            .flatMapLatest { (flowState: Store.FlowState) -> Driver<(Route?, Route, NavigatableController)> in
                return Driver.of((flowState.currentRoute, destinationRoute, flowState.currentRouteNavigatableController))
            }
            .asObservable()
            .take(1)
            .flatMap { (originRoute: Route?, destinationRoute: Route, navigatableController: NavigatableController) -> Observable<ActionType> in
                return NavigateToRootActionCreator.navigate(fromRoute: originRoute, toRoute: destinationRoute, usingNavigatableController: navigatableController, inputs: inputs).asObservable()
            }
            .asDriver(onErrorJustReturn: Store.FlowAction.transissionToRoute(route: Route.root)) // The Observable being converted doesn't emmit errors. Hence, this won't be returned
    }
    
    private static func navigate(
        fromRoute originRoute: Route?
        , toRoute destinationRoute: Route
        , usingNavigatableController navigatableController: NavigatableController
        , inputs: NavigateToRootActionCreator.Inputs
        ) -> Driver<ActionType> {
        
        guard case (nil, Route.root) = (originRoute, destinationRoute) else {
            fatalError("Using wrong dispatcher or the path is not supported")
        }
        
        let result: Driver<ActionType> = Observable.create { (observer: AnyObserver<ActionType>) -> Disposable in
            observer.on(.next(Store.FlowAction.transissionToRoute(route: destinationRoute)))
            let navigationController = NavigationController()
            inputs.window.rootViewController = navigationController
            
            let navigatableController = NavigatableController(
                viewController: navigatableController.viewController
                , navigationController: navigationController
                , tabBarController: navigatableController.tabBarController
            )
            
            let action: ActionType = Store.FlowAction.transissionedToRoute(route: destinationRoute, currentRouteNavigatableController: navigatableController)
            
            observer.on(.next(action))
            observer.on(.completed)

            return Disposables.create()
        }
        .asDriver(onErrorJustReturn: Store.FlowAction.transissionToRoute(route: Route.root)) // The Observable being converted doesn't emmit errors. Hence, this won't be returned
        
        return result
    }
}
