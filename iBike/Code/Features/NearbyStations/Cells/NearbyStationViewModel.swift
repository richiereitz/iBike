//
//  NearbyStationViewModel.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import RxSwift
import RxCocoa
import CoreLocation

final class NearbyStationViewModel: ViewModelProtocol {
    struct Input {}

    struct Output {
        let stationNameDriver: Driver<String>
        let stationDistanceDriver: Driver<String>
    }

    // MARK: - Properties

    let input: Input = Input()
    let output: Output

    private let disposeBag = DisposeBag()
    private let stationDistanceRelay = BehaviorRelay<String>(value: "")
    private let locationManager: LocationManager
    let station: CitiBikeStation

    // MARK: - Lifecycle

    init(station: CitiBikeStation, locationManager: LocationManager = .shared) {
        self.locationManager = locationManager
        self.station = station

        output = Output(
            stationNameDriver: Driver.just(station.name),
            stationDistanceDriver: stationDistanceRelay.asDriver()
        )

        setupBindings()
    }

    // MARK: - Bindings

    private func setupBindings() {
        locationManager.currentLocationDriver.map {[weak self] location -> String in
            guard
                let self = self,
                let currentLocation = location
                else { return "Distance unknown"}

            let stationDistance = self.station.location.distanceInMiles(from: currentLocation)
            return String(format:"%.2f miles away", stationDistance)
        }
        .drive(stationDistanceRelay)
        .disposed(by: disposeBag)
    }
}
