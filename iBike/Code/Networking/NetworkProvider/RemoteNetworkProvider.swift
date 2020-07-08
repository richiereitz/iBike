//
//  RemoteNetworkProvider.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

class RemoteNetworkProvider: NetworkProvider {
    private enum Constants {
        static let defaultTimeout: TimeInterval = 10
    }

    // MARK: - Properties

    static let shared = RemoteNetworkProvider()
    private let session: Session

    // MARK: - Lifecycle

    init(configuration: URLSessionConfiguration = .default, timeout: TimeInterval = Constants.defaultTimeout) {
        configuration.timeoutIntervalForRequest = timeout
        session = Session(configuration: configuration)
    }

    // MARK: - NetworkProvider

    func execute<Object: Decodable>(_ requestConvertible: URLRequestConvertible) -> Single<Object> {
        return Single.create { task in
            let request = self.session.request(requestConvertible)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let decodedObject = try JSONDecoder().decode(Object.self, from: data)
                            task(.success(decodedObject))
                        } catch {
                            task(.error(error))
                        }
                    case .failure(let error):
                        task(.error(error))
                    }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
