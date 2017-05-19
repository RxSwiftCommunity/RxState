//
//  UINavigationController+Rx.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UINavigationController {

    /// Emmits once the proccess is done then completes
    func pushViewController(_ viewController: UIViewController, animated: Bool) -> Observable<Void> {
        return Observable.create { observable -> Disposable in
            CATransaction.begin()
            CATransaction.setCompletionBlock({ 
                observable.on(.next())
                observable.on(.completed)
            })
            self.base.pushViewController(viewController, animated: animated)
            CATransaction.commit()
            return Disposables.create {}
        }
    }

    /// Emmits once the proccess is done then completes
    func popViewController(_ animated: Bool) -> Observable<Void> {
        return Observable.create { observable -> Disposable in
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                observable.on(.next())
                observable.on(.completed)
            })
            self.base.popViewController(animated: animated)
            CATransaction.commit()
            return Disposables.create {}
        }
    }

    /// Emmits once the proccess is done then completes
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) -> Observable<Void> {
        return Observable.create { observable -> Disposable in
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                observable.on(.next())
                observable.on(.completed)
            })
            self.base.setViewControllers(viewControllers, animated: animated)
            CATransaction.commit()
            return Disposables.create {}
        }
    }
}
