//
//  ViewModelProtocol.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import Foundation

protocol ViewModelProtocol {
    associatedtype Input
    associatedtype Output

    var input: Input { get }
    var output: Output { get }
}
