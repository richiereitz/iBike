//
//  StationDetailsSectionModel.swift
//  iBike
//
//  Created by richard.reitzfeld on 7/1/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import RxDataSources

extension StationDetailsViewController {
    struct StationDetailsSectionModel {
        var items: [StationDetailsViewModel.DetailsSectionType]
    }
}

extension StationDetailsViewController.StationDetailsSectionModel: SectionModelType {
    init(original: StationDetailsViewController.StationDetailsSectionModel, items: [StationDetailsViewModel.DetailsSectionType]) {
        self = original
        self.items = items
    }
}
