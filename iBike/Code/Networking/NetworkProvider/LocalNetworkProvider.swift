//
//  LocalNetworkProvider.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import RxSwift
import Alamofire

class LocalNetworkProvider: NetworkProvider {

    // MARK: - NetworkProvider
    
    func execute<Object: Decodable>(_ requestConvertible: URLRequestConvertible) -> Single<Object> {
        return Single.create { task in
            guard let path = Bundle.main.url(forResource: String(describing: Object.self), withExtension: "json") else {
                task(.error(NetworkError.customError("Failed to find local data file named: \(String(describing: Object.self)).json")))
                return Disposables.create()
            }
            do {
                let data = try Data(contentsOf: path)
                let response = try JSONDecoder().decode(Object.self, from: data)
                task(.success(response))
            } catch {
                task(.error(error))
            }
            return Disposables.create()
        }
    }
}
