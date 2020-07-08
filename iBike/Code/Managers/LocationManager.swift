//
//  LocationManager.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

class LocationManager: NSObject, CLLocationManagerDelegate, LocationManaging {

    // MARK: - Properties

    static let shared = LocationManager()

    private let locationManager = CLLocationManager()
    private let disposeBag = DisposeBag()

    var currentLocationPermissions: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    var locationPermissionObservable: Observable<CLAuthorizationStatus> {
        return locationPermissionRelay.asObservable()
    }
    private let locationPermissionRelay = BehaviorRelay<CLAuthorizationStatus>(value: CLLocationManager.authorizationStatus())

    var currentLocationDriver: Driver<CLLocation?> {
        return currentLocationRelay.asDriver()
    }

    private let currentLocationRelay = BehaviorRelay<CLLocation?>(value: nil)

    // MARK: - Lifecycle

    private override init() {
        super.init()

        locationManager.delegate = self
        // Various accuracies affect the amount of time required to get location, especially for one off location requests. Would want to fiddle with this with more time
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    // MARK: - Request

    func requestWhenInUse() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestCurrentLocationUpdate() {
        locationManager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationPermissionRelay.accept(status)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        currentLocationRelay.accept(currentLocation)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error updating location: \(error)")
    }
}
