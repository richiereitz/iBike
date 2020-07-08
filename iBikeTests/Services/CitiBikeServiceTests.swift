//
//  CitiBikeServiceTests.swift
//  iBikeTests
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import XCTest
import RxSwift
@testable import iBike

class CitiBikeServiceTests: XCTestCase {

    let service = CitiBikeService(networkProvider: LocalNetworkProvider())
    var disposeBag = DisposeBag()

    override func tearDown() {
        disposeBag = DisposeBag()
    }

    func testGetCitiBikeData() {
        let citiBikeDataExpectation = expectation(description: "Got citibike data")

        service.getCitiBikeStations()
            .subscribe(onSuccess: { container in
                XCTAssert(container.data.stations.count == 1008)
                citiBikeDataExpectation.fulfill()
            }) { error in
                print("Failed to get citibike data: \(error)")
        }.disposed(by: disposeBag)

        wait(for: [citiBikeDataExpectation], timeout: 10)
    }
}
