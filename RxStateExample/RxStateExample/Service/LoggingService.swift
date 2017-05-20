//
//  LoggingService.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxSwift
import RxState
import RxCocoa

protocol LoggingServiceType: Middleware, HasDisposeBag {}

final class LoggingService: LoggingServiceType {
    var disposeBag = DisposeBag()

    func observe(currentStateLastAction: Driver<CurrentStateLastAction>) {
        currentStateLastAction
            .drive(
                onNext: { (currentState: [SubstateType], lastAction: ActionType?) in
                    print("\n---------------------------------------------")
                    print("\n*************** Current State ***************")
                    print(currentState)
                    print("\n************* Dispatched Action *************")
                    if let lastAction = lastAction {
                        print(lastAction)
                    } else {
                        print("No action has been dispatched yet")
                    }
            }
                , onCompleted: nil
                , onDisposed: nil
            )
            .disposed(by: disposeBag)
    }
}
