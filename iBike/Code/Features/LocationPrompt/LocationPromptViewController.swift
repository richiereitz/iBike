//
//  LocationPromptViewController.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

final class LocationPromptViewController: UIViewController {
    private enum Constants {
        static let logoImageViewTopPadding: CGFloat = 50.0

        static let prompLabelText: String = "We need to use your location in order to help you find CitiBikes near you"
        static let promptLabelHorizontalPadding: CGFloat = 20.0
        static let promptLabelTopPadding: CGFloat = 50.0

        static let useMyLocationButtonText: String = "Use My Location"
        static let useMyLocationButtonHeight: CGFloat = 50.0
        static let useMyLocationButtonWidth: CGFloat = 200.0
    }

    // MARK: - Properties

    private let viewModel = LocationPromptViewModel()
    private let disposeBag = DisposeBag()
    private let logoImageView = UIImageView(image: .citiBikeLogo)

    private let promptLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.text = Constants.prompLabelText
        label.textColor = .white
        label.font = .systemFont(ofSize: 20.0, weight: .light)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()

    private let useMyLocationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.setTitle(Constants.useMyLocationButtonText, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.useMyLocationButtonHeight / 2.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.0
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .citiBlueColor

        view.addSubview(logoImageView)
        view.addSubview(promptLabel)
        view.addSubview(useMyLocationButton)

        setupConstraints()
        setupBindings()
    }

    // MARK: - Layout

    private func setupConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constants.logoImageViewTopPadding)
        }

        promptLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(Constants.promptLabelTopPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.promptLabelHorizontalPadding * 2.0)
        }

        useMyLocationButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(Constants.useMyLocationButtonWidth)
            make.height.equalTo(Constants.useMyLocationButtonHeight)
        }
    }

    // MARK: - Binding

    private func setupBindings() {
        useMyLocationButton.rx.tap
            .bind(to: viewModel.input.useMyLocationButtonTappedObserver)
            .disposed(by: disposeBag)
    }
}
