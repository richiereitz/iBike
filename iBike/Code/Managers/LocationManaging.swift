//
//  LocationManaging.swift
//  iBike
//
//  Created by richard.reitzfeld on 7/7/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

protocol LocationManaging {
    var currentLocationPermissions: CLAuthorizationStatus { get }
    var locationPermissionObservable: Observable<CLAuthorizationStatus> { get }
    var currentLocationDriver: Driver<CLLocation?>  { get }
    func requestCurrentLocationUpdate()
    func requestWhenInUse()
}
