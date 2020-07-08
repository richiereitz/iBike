//
//  StationDetailTableViewCell.swift
//  iBike
//
//  Created by richard.reitzfeld on 7/1/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import RxSwift
import RxCocoa

final class StationDetailTableViewCell: UITableViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "StationDetailTableViewCell"
    private var disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.lineBreakMode = .byWordWrapping
        textLabel?.numberOfLines = 0
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

    func bind(to viewModel: StationDetailViewModel) {
        guard let textLabel = textLabel else { return }
        viewModel.output.stationDetailDriver
            .drive(textLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
