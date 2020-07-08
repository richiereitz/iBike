//
//  NearbyStationTableViewCell.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class NearbyStationTableViewCell: UITableViewCell {

    // MARK: - Properties

    static let reuseIdentifier: String = "NearbyStationTableViewCell"
    private var disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    // MARK: - Binding
    func bind(to viewModel: NearbyStationViewModel) {
        guard
            let textLabel = textLabel,
            let detailTextLabel = detailTextLabel
            else { return }

        viewModel.output.stationNameDriver
            .drive(textLabel.rx.text)
        .disposed(by: disposeBag)
        
        viewModel.output.stationDistanceDriver
            .drive(detailTextLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
