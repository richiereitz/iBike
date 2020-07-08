//
//  NearbyStationViewModelTests.swift
//  iBikeTests
//
//  Created by richard.reitzfeld on 7/8/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import XCTest
import RxSwift
@testable import iBike

class NearbyStationViewModelTests: XCTestCase {

    let locationManager = MockLocationManager()
    let citibikeService = CitiBikeService(networkProvider: LocalNetworkProvider())
    var disposeBag = DisposeBag()

    var localStations: [CitiBikeStation] = {
        guard let path = Bundle.main.url(forResource: String(describing: CitiBikeDataContainer.self), withExtension: "json") else {
            XCTAssert(false, "Path  should exist")
            return []
        }
        do {
            let data = try Data(contentsOf: path)
            let response = try JSONDecoder().decode(CitiBikeDataContainer.self, from: data)
            XCTAssert(response.data.stations.count == 1008, "Stations should match JSON file")
            return response.data.stations
        } catch {
            XCTAssert(false, "Decoding Error")
        }
        return []
    }()

    override func tearDown() {
        disposeBag = DisposeBag()
    }

    func testStationDistance() {
        let viewModel = NearbyStationViewModel(station: localStations[0])
        viewModel.output.stationDistanceDriver.drive(onNext: { stationDistanceString in
            print(stationDistanceString)
            XCTAssert(stationDistanceString == "2570.88 miles away", "Should provide formatted distance")
        }).disposed(by: disposeBag)
    }
}
