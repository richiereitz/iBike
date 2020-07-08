//
//  Request.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import Foundation
import Alamofire

enum RequestError: Error {
    case invalidPath
}

struct Request {

    // MARK: - Properties

    let baseURLString: String
    let method: HTTPMethod
    let path: String

    // MARK: - Lifecycle

    init(method: HTTPMethod, baseURLString: String, path: String) {
        self.baseURLString = baseURLString
        self.method = method
        self.path = path
    }
}

extension Request: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        guard
            let baseURL = URL(string: baseURLString),
            let url = URL(string: path, relativeTo: baseURL)
            else {
                throw RequestError.invalidPath
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        return request as URLRequest
    }
}
