//
//  StationDetailViewModel.swift
//  iBike
//
//  Created by richard.reitzfeld on 7/1/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import RxSwift
import RxCocoa

final class StationDetailViewModel: ViewModelProtocol {
    struct Input {}

    struct Output {
        let stationDetailDriver: Driver<String>
    }

    // MARK: - Properties

    let input: Input = Input()
    let output: Output

    // MARK: - Lifecycle

    init(detail: String) {
        output = Output(
            stationDetailDriver: Driver.just(detail)
        )
    }
}
