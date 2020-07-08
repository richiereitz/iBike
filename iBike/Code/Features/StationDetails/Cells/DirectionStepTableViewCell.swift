//
//  DirectionStepTableViewCell.swift
//  iBike
//
//  Created by richard.reitzfeld on 7/1/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import RxSwift
import RxCocoa

final class DirectionStepTableViewCell: UITableViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "DirectionStepTableViewCell"
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

    func bind(to viewModel: DirectionStepViewModel) {
        guard
            let textLabel = textLabel,
            let detailTextLabel = detailTextLabel
            else { return }

        viewModel.output.instructionTextDriver
            .drive(textLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.distanceTextDriver
            .drive(detailTextLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
