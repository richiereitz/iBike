//
//  NetworkProvider.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire

enum NetworkError: Error, CustomStringConvertible {
    case unknownError
    case customError(String)

    var description: String {
        switch self {
        case .unknownError:
            return "Unknown error occured."
        case .customError(let errorMessage):
            return errorMessage
        }
    }
}

protocol NetworkProvider {
    func execute<Object: Decodable>(_ requestConvertible: URLRequestConvertible) -> Single<Object>
}
