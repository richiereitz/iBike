//
//  CitiBikeData.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

/*
{
   "stations": []
}
*/

import Foundation

struct CitiBikeData: Decodable {
    // MARK: - Properties
    
    var stations: [CitiBikeStation]
}
