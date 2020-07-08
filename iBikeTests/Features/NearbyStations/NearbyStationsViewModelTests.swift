//
//  NearbyStationsViewModelTests.swift
//  iBikeTests
//
//  Created by richard.reitzfeld on 7/8/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import XCTest
import RxSwift
@testable import iBike

class NearbyStationsViewModelTests: XCTestCase {

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

    func testStationsRequestDriver() {
        let citiBikeDataExpectation = expectation(description: "Got citibike data")
        let viewModel = NearbyStationsViewModel(citiBikeService: citibikeService, locationManager: locationManager)
        viewModel.output.stationsDriver
            .drive(onNext: { stations in
                XCTAssert(stations.count == 1008)
                citiBikeDataExpectation.fulfill()
            }).disposed(by: disposeBag)

        wait(for: [citiBikeDataExpectation], timeout: 10)
    }

    func testGetCurrentLocation() {
        let locationExpectation = expectation(description: "Location will be NYC location")
        let viewModel = NearbyStationsViewModel(citiBikeService: citibikeService, locationManager: locationManager)

        viewModel.output.currentLocationDriver
            .drive(onNext: { location in
                XCTAssert(location == MockLocationManager.Constants.nycLocation, "Should be NYC location")
                locationExpectation.fulfill()
            }).disposed(by: disposeBag)

        wait(for: [locationExpectation], timeout: 10)
    }

    func testSortStations() {
        let mockStationOne = localStations[0].location
        let mockStationtwo = localStations[1].location
        let citiBikeDataExpectation = expectation(description: "Got citibike data")
        let viewModel = NearbyStationsViewModel(citiBikeService: citibikeService, locationManager: locationManager)
        viewModel.output.stationsDriver
            .drive(onNext: { stations in
                let stationOne = stations[0].station.location
                let stationTwo = stations[1].station.location
                XCTAssert(stationOne.distance(from: MockLocationManager.Constants.nycLocation) < stationTwo.distance(from: MockLocationManager.Constants.nycLocation))
                XCTAssert(stationOne != mockStationOne, "Should be sorted")
                XCTAssert(stationTwo != mockStationtwo, "Should be sorted")
                citiBikeDataExpectation.fulfill()
            }).disposed(by: disposeBag)

        wait(for: [citiBikeDataExpectation], timeout: 10)
    }

    func testPresentStationDetailsSignal() {
        let stationDetailsExpectation = expectation(description: "Should be StationDetails")
        let viewModel = NearbyStationsViewModel(citiBikeService: citibikeService, locationManager: locationManager)
        viewModel.output.presentStationDetailsSignal
            .emit(onNext: { viewController in
                guard let nav = viewController as? UINavigationController else {
                    XCTAssert(false, "Should be navigation controller")
                    return
                }
                XCTAssert(nav.viewControllers[0] is StationDetailsViewController, "Should be StationDetailsViewController")
                stationDetailsExpectation.fulfill()
            }).disposed(by: disposeBag)

        viewModel.input.stationSelectedObserver.onNext(localStations[0])
        
        wait(for: [stationDetailsExpectation], timeout: 10)
    }
}
