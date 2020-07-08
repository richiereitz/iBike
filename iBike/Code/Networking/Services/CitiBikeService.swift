//
//  CitiBikeService.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

fileprivate enum Constants {
    static let baseURLString: String = "https://gbfs.citibikenyc.com/"
    static let defaultPathComponents: String = "gbfs/es/"
    static let stationsPathComponent: String = "station_information.json"
}

final class CitiBikeService: Service {

    // MARK: - Properties

    let networkProvider: NetworkProvider

    // MARK: - Lifecycle

    init(networkProvider: NetworkProvider = RemoteNetworkProvider.shared) {
        self.networkProvider = networkProvider
    }

    // MARK: - Requests

    func getCitiBikeStations() -> Single<CitiBikeDataContainer> {
        return networkProvider.execute(Request.getCitiBikeStationsRequest())
    }
}

fileprivate extension Request {
    static func getCitiBikeStationsRequest() -> Request {
        return Request(
            method: .get,
            baseURLString: Constants.baseURLString,
            path: Constants.defaultPathComponents + Constants.stationsPathComponent
        )
    }
}
