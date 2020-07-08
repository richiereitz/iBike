//
//  NearbyStationsSectionModel.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import RxDataSources

extension NearbyStationsViewController {
    struct NearbyStationSectionModel {
        var items: [NearbyStationViewModel]
    }
}

extension NearbyStationsViewController.NearbyStationSectionModel: SectionModelType {
    init(original: NearbyStationsViewController.NearbyStationSectionModel, items: [NearbyStationViewModel]) {
        self = original
        self.items = items
    }
}
