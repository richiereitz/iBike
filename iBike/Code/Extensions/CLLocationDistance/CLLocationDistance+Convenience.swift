//
//  CLLocationDistance+Convenience.swift
//  iBike
//
//  Created by richard.reitzfeld on 7/1/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import CoreLocation

extension CLLocationDistance {
    func toMiles() -> Double {
        let metersToMilesMultiplier: Double = 0.000621371
        return self * metersToMilesMultiplier
    }
}
