//
//  LocationPromptViewModelTests.swift
//  iBikeTests
//
//  Created by richard.reitzfeld on 7/8/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import XCTest
import RxSwift
@testable import iBike

class LocationPromptViewModelTests: XCTestCase {

    let locationManager = MockLocationManager()
    lazy var viewModel = LocationPromptViewModel(locationManager: locationManager)
    var disposeBag = DisposeBag()

    override func tearDown() {
        disposeBag = DisposeBag()
    }

    func testUseMyLocationRequest() {
        XCTAssert(locationManager.currentLocationPermissions == .notDetermined, "Should be .notDetermined")
        viewModel.input.useMyLocationButtonTappedObserver.onNext(())
        XCTAssert(locationManager.currentLocationPermissions == .authorizedWhenInUse, "Should be .whenInUse")
    }
}
