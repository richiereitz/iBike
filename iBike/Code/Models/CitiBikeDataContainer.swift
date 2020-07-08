//
//  CitiBikeDataContainer.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

/*
{
   "data": {
       "stations": []
   },
   "last_updated": 1593538135,
   "ttl": 300
}
*/

import Foundation

struct CitiBikeDataContainer: Decodable {
    // MARK: - Properties
    
    var data: CitiBikeData
}
