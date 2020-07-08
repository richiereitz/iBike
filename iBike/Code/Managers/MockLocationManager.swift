//
//  MockLocationManager.swift
//  iBike
//
//  Created by richard.reitzfeld on 7/7/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

class MockLocationManager: LocationManaging {
    enum Constants {
        static let nycLocation = CLLocation(latitude: 40.730610, longitude: 40.730610)
    }

    var currentLocationPermissions: CLAuthorizationStatus = .notDetermined {
        didSet {
            locationPermissionRelay.accept(currentLocationPermissions)
        }
    }
    private let locationPermissionRelay = BehaviorRelay<CLAuthorizationStatus>(value: .notDetermined)
    var locationPermissionObservable: Observable<CLAuthorizationStatus> {
        return locationPermissionRelay.asObservable()
    }

    var currentLocationDriver: Driver<CLLocation?> {
        return currentLocationRelay.asDriver()
    }
    private let currentLocationRelay = BehaviorRelay<CLLocation?>(value: nil)

    func requestCurrentLocationUpdate() {
        currentLocationRelay.accept(Constants.nycLocation)
    }

    func requestWhenInUse() {
        currentLocationPermissions = .authorizedWhenInUse
    }

    func revokeWhenInUse() {
        currentLocationPermissions = .notDetermined
    }

    func resetCurrentLocation() {
        currentLocationRelay.accept(nil)
    }
}
