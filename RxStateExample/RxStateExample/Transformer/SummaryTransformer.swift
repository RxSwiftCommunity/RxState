//
//  SummaryTransformer.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxCocoa
import RxState

final class SummaryTransformer {
    struct Inputs: TransformerInputsType {
        let store: StoreType
        let taskId: TaskId
    }
    
    struct Outputs: TransformerOutputsType {
        let summary: Driver<String>
    }
    
    static func transtorm(inputs: SummaryTransformer.Inputs) -> SummaryTransformer.Outputs {
        let summary = inputs.store.task(withId: inputs.taskId)
            .map { (task: Task) -> String in task.summary }
            .distinctUntilChanged()
        
        return SummaryTransformer.Outputs(summary: summary)
    }
}
