//
//  UINavigationController+Rx.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UINavigationController {

    /// Emmits once the proccess is done then completes
    func pushViewController(_ viewController: UIViewController, animated: Bool) -> Driver<Void> {
        return Observable.create { observable -> Disposable in
            CATransaction.begin()
            CATransaction.setCompletionBlock({ 
                observable.on(.next({}()))
                observable.on(.completed)
            })
            self.base.pushViewController(viewController, animated: animated)
            CATransaction.commit()
            
            return Disposables.create {}
        }
        .asDriver(onErrorJustReturn: ()) // Will never happen since there's no error throwing in the Observable creation.
    }

    /// Emmits once the proccess is done then completes
    func popViewController(_ animated: Bool) -> Driver<Void> {
        return Observable.create { observable -> Disposable in
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                observable.on(.next({}()))
                observable.on(.completed)
            })
            self.base.popViewController(animated: animated)
            CATransaction.commit()
            return Disposables.create {}
        }
            .asDriver(onErrorJustReturn: ()) // Will never happen since there's no error throwing in the Observable creation.
    }

    /// Emmits once the proccess is done then completes
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) -> Driver<Void> {
        return Observable.create { observable -> Disposable in
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                observable.on(.next({}()))
                observable.on(.completed)
            })
            self.base.setViewControllers(viewControllers, animated: animated)
            CATransaction.commit()
            return Disposables.create {}
        }
            .asDriver(onErrorJustReturn: ()) // Will never happen since there's no error throwing in the Observable creation.
    }
}
