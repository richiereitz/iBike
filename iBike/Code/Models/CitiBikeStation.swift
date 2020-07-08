//
//  CitiBikeStation.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

/*
{
   "rental_url": "http://app.citibikenyc.com/S6Lr/IBV092JufD?station_id=72",
   "lat": 40.76727216,
   "station_type": "classic",
   "lon": -73.99392888,
   "rental_methods": [
       "KEY",
       "CREDITCARD"
   ],
   "electric_bike_surcharge_waiver": false,
   "short_name": "6926.01",
   "capacity": 55,
   "has_kiosk": true,
   "external_id": "66db237e-0aca-11e7-82f6-3863bb44ef7c",
   "eightd_station_services": [],
   "name": "W 52 St & 11 Ave",
   "station_id": "72",
   "eightd_has_key_dispenser": false,
   "region_id": "71"
}
*/

import Foundation
import CoreLocation
import MapKit

class CitiBikeStation: NSObject, Decodable, MKAnnotation {

    // MARK: - Decodable

    private enum CodingKeys: String, CodingKey {
        case rentalURLString = "rental_url"
        case latitude = "lat"
        case stationType = "station_type"
        case longitude = "lon"
        case rentalMethods = "rental_methods"
        case electricBikeSurchargeWaiver = "electric_bike_surcharge_waiver"
        case shortName = "short_name"
        case capacity
        case hasKiosk = "has_kiosk"
        case externalId = "external_id"
        case name
        case hasKeyDispenser = "eightd_has_key_dispenser"
        case regionId = "region_id"
    }

    // MARK: - Properties

    let rentalURLString: String
    let latitude: Double
    let stationType: String
    let longitude: Double
    let rentalMethods: [String]
    let electricBikeSurchargeWaiver: Bool
    let shortName: String
    let capacity: Int
    let hasKiosk: Bool
    let externalId: String
    let name: String
    let hasKeyDispenser: Bool
    let regionId: String

    var location: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }

    // MARK: - MKAnnotation

    var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }

    var title: String? {
        return name
    }

    var subtitle: String? {
        return stationType
    }
}
