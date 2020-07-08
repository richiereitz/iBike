//
//  DirectionStepViewModel.swift
//  iBike
//
//  Created by richard.reitzfeld on 7/1/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import RxSwift
import RxCocoa
import MapKit

final class DirectionStepViewModel: ViewModelProtocol {
    struct Input {}

    struct Output {
        let instructionTextDriver: Driver<String>
        let distanceTextDriver: Driver<String>
    }

    // MARK: - Properties

    let input: Input = Input()
    let output: Output

    // MARK: - Lifecycle

    init(step: MKRoute.Step) {
        output = Output(
            instructionTextDriver: Driver.just(step.instructions),
            distanceTextDriver: Driver.just(String(format:"%.2f miles", step.distance.toMiles()))
        )
    }
}
