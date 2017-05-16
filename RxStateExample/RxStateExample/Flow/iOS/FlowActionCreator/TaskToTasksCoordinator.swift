//
//  TaskToTasksActionCreator.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxSwift
import RxCocoa
import RxState

final class TaskToTasksCoordinator: FlowCoordinatorType {    
    struct Inputs: ActionCreatorInputsType {
        let store: StoreType
    }
    
    static func create(inputs: TaskToTasksCoordinator.Inputs) -> Driver<ActionType> {
        
        let destinationRoute = Route.tasks
        
        return inputs.store.flowState
            .flatMapLatest { (flowState: Store.FlowState) -> Driver<(Route?, Route, NavigatableController)> in
                return Driver.of((flowState.currentRoute, destinationRoute, flowState.currentRouteNavigatableController))
            }
            .asObservable()
            .take(1)
            .flatMap { (originRoute: Route?, destinationRoute: Route, navigatableController: NavigatableController) -> Observable<ActionType> in
                return TaskToTasksCoordinator.navigate(fromRoute: originRoute, toRoute: destinationRoute, usingNavigatableController: navigatableController, inputs: inputs).asObservable()
            }
            .asDriver(onErrorJustReturn: Store.FlowAction.transissionToRoute(route: Route.root)) // The Observable being converted doesn't emmit errors. Hence, this won't be returned
    }
    
    private static func navigate(
        fromRoute originRoute: Route?
        , toRoute destinationRoute: Route
        , usingNavigatableController navigatableController: NavigatableController
        , inputs: TaskToTasksCoordinator.Inputs
        ) -> Driver<ActionType> {
        
        guard let navigationController: UINavigationController = navigatableController.navigationController else {
            fatalError("A navigation controller is needed to perform this transission.\nCurrent navigatableController: \(navigatableController)")
        }
        
        guard case (Route.task?, Route.tasks) = (originRoute, destinationRoute) else {
            fatalError("Using wrong dispatcher or the path is not supported")
        }
        
        let result: Driver<ActionType> = navigationController.rx.popViewController(true)
            .map { _ -> ActionType in
                let navigatableController: NavigatableController = NavigatableController(
                    viewController: navigationController.topViewController
                    , navigationController: navigationController
                    , tabBarController: navigatableController.tabBarController
                )
                
                let result: ActionType = Store.FlowAction.transissionedToRoute(route: destinationRoute, currentRouteNavigatableController: navigatableController)
                return result
            }
            .startWith(Store.FlowAction.transissionToRoute(route: destinationRoute))
        
        return result
    }
}
