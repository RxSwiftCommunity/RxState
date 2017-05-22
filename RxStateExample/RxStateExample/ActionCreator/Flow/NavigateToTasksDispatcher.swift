//
//  OpenTasksDispatcher.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxSwift
import RxCocoa
import RxState

class OpenTaskDispatcher {
    struct Inputs {
        let openTaskButtonDidTap: ControlEvent<Void>
        let navigatableNavigationController: NavigationController
        let taskId: TaskId
    }
    
    static func dispatch(onStore store: StoreType, inputs: OpenTaskDispatcher.Inputs) -> Disposable {
        return inputs.openTaskButtonDidTap
            .flatMapLatest { _ -> Driver<(Route?, Route)> in
                let originRoute: Driver<Route?> = store.flowState
                    .map { (state: FlowStateManager.State) -> Route? in
                        return state.currentRoute
                }
                
                let destinationRoute: Driver<Route> = store.task(withId: inputs.taskId)
                    .map { (task: Task) -> Route in
                        return Route.task(id: task.id)
                }
                
                return Driver.combineLatest(originRoute, destinationRoute)
                
            }
            .flatMapLatest{ (originRoute: Route?, destinationRoute: Route) -> Driver<FlowStateManager.Action> in
                return OpenTaskDispatcher.transission(fromRoute: originRoute, toRoute: destinationRoute, usingNavigatableNavigationController: inputs.navigatableNavigationController)
            }
            .subscribe(
                onNext: { (action: FlowStateManager.Action) in
                    store.dispatch(action: action)
            }, onError: nil, onCompleted: nil, onDisposed: nil
        )
    }
    
    private static func transission(fromRoute originRoute: Route?, toRoute destinationRoute: Route, usingNavigatableNavigationController navigatableNavigationController: UINavigationController) -> Driver<FlowStateManager.Action> {
        
        
        guard case (.tasks?, let .task(id)) = (originRoute, destinationRoute) else {
            fatalError("Using wrong dispatcher of the path is not supported")
        }
        
        return Driver.of(FlowStateManager.Action.transissionToRoute(route: destinationRoute))
            .flatMap { _ -> Driver<FlowStateManager.Action> in
                let viewModel = TaskViewControllerViewModel(store: store, taskId: id)
                let viewController = TaskViewController.build(withViewModel: viewModel)
                viewController.addBackButton()
                viewController.edgesForExtendedLayout = []
                return navigatableNavigationController.rx
                    .pushViewController(viewController, animated: true)
                    .map { (_) -> FlowStateManager.Action in
                        FlowStateManager.Action.transissionedToRoute(route: destinationRoute)
                }
        }
    }
}
