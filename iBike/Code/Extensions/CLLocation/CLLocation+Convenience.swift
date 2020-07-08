//
//  CLLocation+Convenience.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import CoreLocation

extension CLLocation {
    func distanceInMiles(from location: CLLocation) -> Double {
        return distance(from: location).toMiles()
    }
}
