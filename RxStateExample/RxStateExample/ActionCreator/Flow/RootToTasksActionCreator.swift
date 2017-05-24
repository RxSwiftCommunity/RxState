//
//  RootToTasksActionCreator.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxSwift
import RxCocoa
import RxState

final class NavigateRootToTasksActionCreator: FlowActionCreatorType {
    struct Inputs: ActionCreatorInputsType {
        let store: StoreType
    }
    
    static func create(inputs: NavigateRootToTasksActionCreator.Inputs) -> Driver<ActionType> {

//        let destinationRoute = Driver.just(Route.tasks)
//        
//        return destinationRoute
//            .withLatestFrom(inputs.store.flowState, resultSelector: { (destinationRoute: Route, flowState: Store.FlowState) -> (Route?, Route, NavigatableController) in
//                return (flowState.currentRoute, destinationRoute, flowState.currentRouteNavigatableController)
//            })
//            .flatMap{ (originRoute: Route?, destinationRoute: Route, navigatableController: NavigatableController) -> Driver<ActionType> in
//                return RootToTasksActionCreator.transission(fromRoute: originRoute, toRoute: destinationRoute, usingNavigatableController: navigatableController, inputs: inputs)
//        }

        // Any better wat to make this complete after taking one `inputs.store.flowState` element? The above didn't worl when it was used with concat!
        
        let destinationRoute = Route.tasks

        return inputs.store.flowState
            .flatMapLatest { (flowState: Store.FlowState) -> Driver<(Route?, Route, NavigatableController)> in
                return Driver.of((flowState.currentRoute, destinationRoute, flowState.currentRouteNavigatableController))
            }
            .asObservable()
            .take(1)
            .flatMap { (originRoute: Route?, destinationRoute: Route, navigatableController: NavigatableController) -> Observable<ActionType> in
                return NavigateRootToTasksActionCreator.navigate(fromRoute: originRoute, toRoute: destinationRoute, usingNavigatableController: navigatableController, inputs: inputs).asObservable()
            }
            .asDriver(onErrorJustReturn: Store.FlowAction.transissionToRoute(route: Route.root)) // The Observable being converted doesn't emmit errors. Hence, this won't be returned
        
    }
    
    private static func navigate(
        fromRoute originRoute: Route?
        , toRoute destinationRoute: Route
        , usingNavigatableController navigatableController: NavigatableController
        , inputs: NavigateRootToTasksActionCreator.Inputs
        ) -> Driver<ActionType> {
        
        guard let navigationController = navigatableController.navigationController else {
            fatalError("This route needs a navgatable navigation controller to complete")
        }

        guard case (.root?, .tasks) = (originRoute, destinationRoute) else {
            fatalError("Using wrong dispatcher or the path is not supported")
        }
        
        let result: Driver<ActionType> = Observable.create { (observer: AnyObserver<ActionType>) -> Disposable in
            observer.on(.next(Store.FlowAction.transissionToRoute(route: destinationRoute)))
            let tasksViewControllerViewModel = TasksViewControllerViewModel(store: inputs.store)
            let viewController = TasksViewController.build(withViewModel: tasksViewControllerViewModel)
            navigationController.setViewControllers([viewController], animated: false)
            
            let navigatableController = NavigatableController(
                viewController: viewController
                , navigationController: navigatableController.navigationController
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
