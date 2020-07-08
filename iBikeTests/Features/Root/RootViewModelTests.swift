//
//  RootViewModelTests.swift
//  iBikeTests
//
//  Created by richard.reitzfeld on 7/8/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import XCTest
import RxSwift
@testable import iBike

class RootViewModelTests: XCTestCase {

    let locationManager = MockLocationManager()
    lazy var viewModel = RootViewModel(locationManager: locationManager)
    var disposeBag = DisposeBag()

    override func tearDown() {
        disposeBag = DisposeBag()
    }

    func testNearbyStationsRequired() {
        let nearbyViewControllerExpectation = expectation(description: "Root Is NearbyViewController")

        viewModel.output.newChildViewControllerRequiredSignal
            .emit(onNext: { viewController in
                guard let nav = viewController as? UINavigationController else {
                    XCTAssert(false, "Should be navigation controller")
                    return
                }
                XCTAssert(nav.viewControllers[0] is NearbyStationsViewController, "Should be NearbyStationsViewController")
                nearbyViewControllerExpectation.fulfill()
            }).disposed(by: disposeBag)

        locationManager.requestWhenInUse()

        wait(for: [nearbyViewControllerExpectation], timeout: 10)
    }

    func testLocationPromptRequired() {
        let locationPromptViewControllerExpectation = expectation(description: "LocationPromptViewController is returned")

        viewModel.output.newChildViewControllerRequiredSignal
            .emit(onNext: { viewController in
                XCTAssert(viewController is LocationPromptViewController, "Should be LocationPromptViewController")
                locationPromptViewControllerExpectation.fulfill()
            }).disposed(by: disposeBag)

        locationManager.revokeWhenInUse()

        wait(for: [locationPromptViewControllerExpectation], timeout: 10)
    }
}
