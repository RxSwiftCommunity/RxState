//
//  TasksToTaskActionCreator.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxSwift
import RxCocoa
import RxState

final class NavigateTasksToTaskActionCreator: FlowActionCreatorType {
    typealias I = NavigateTasksToTaskActionCreator.Inputs

    struct Inputs: ActionCreatorInputsType {
        let store: StoreType
        let taskId: TaskId
    }
    
    static func create(inputs: NavigateTasksToTaskActionCreator.Inputs) -> Driver<ActionType> {
        let destinationRoute = Route.task(id: inputs.taskId)
        
        return inputs.store.flowState
            .flatMapLatest { (flowState: Store.FlowState) -> Driver<(Route?, Route, NavigatableController)> in
                return Driver.of((flowState.currentRoute, destinationRoute, flowState.currentRouteNavigatableController))
            }
            .asObservable()
            .take(1)
            .flatMap { (originRoute: Route?, destinationRoute: Route, navigatableController: NavigatableController) -> Observable<ActionType> in
                return NavigateTasksToTaskActionCreator.navigate(fromRoute: originRoute, toRoute: destinationRoute, usingNavigatableController: navigatableController, inputs: inputs).asObservable()
            }
            .asDriver(onErrorJustReturn: Store.FlowAction.transissionToRoute(route: Route.root)) // The Observable being converted doesn't emmit errors. Hence, this won't be returned
    }
    
    private static func navigate(fromRoute originRoute: Route?, toRoute destinationRoute: Route, usingNavigatableController navigatableController: NavigatableController, inputs: NavigateTasksToTaskActionCreator.Inputs) -> Driver<ActionType> {
        
        guard let navigationController = navigatableController.navigationController else {
            fatalError("A navigation controller is needed to perform this transission.\nCurrent navigatableController: \(navigatableController)")
        }

        guard case (.tasks?, let .task(id)) = (originRoute, destinationRoute) else {
            fatalError("Using wrong dispatcher or the path is not supported")
        }
        
        let viewModel = TaskViewControllerViewModel(store: inputs.store, taskId: id)
        let viewController = TaskViewController.build(withViewModel: viewModel)
        viewController.addBackButton()
        viewController.edgesForExtendedLayout = []

        let result: Driver<ActionType> = navigationController.rx.pushViewController(viewController, animated: true)
            .map { _ -> ActionType in
                let navigatableController = NavigatableController(
                    viewController: viewController
                    , navigationController: navigatableController.navigationController
                    , tabBarController: navigatableController.tabBarController
                )
                
                let result: ActionType = Store.FlowAction.transissionedToRoute(route: destinationRoute, currentRouteNavigatableController: navigatableController)
                return result
            }
            .startWith(Store.FlowAction.transissionToRoute(route: destinationRoute))
        
        return result
    }
}
