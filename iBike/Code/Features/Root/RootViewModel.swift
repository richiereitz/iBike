//
//  RootViewModel.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import RxSwift
import RxCocoa

class RootViewModel: ViewModelProtocol {
    struct Input {}

    struct Output {
        let newChildViewControllerRequiredSignal: Signal<UIViewController>
    }

    // MARK: - Properties

    let input: Input = Input()
    let output: Output

    private let disposeBag = DisposeBag()

    private let locationManager: LocationManaging

    private let newChildViewControllerRequiredRelay = PublishRelay<UIViewController>()

    // MARK: - Lifecycle

    init(locationManager: LocationManaging = LocationManager.shared) {
        self.locationManager = locationManager

        output = Output(
            newChildViewControllerRequiredSignal: newChildViewControllerRequiredRelay.asSignal()
        )

        setupBindings()
    }

    // MARK: - Bindings

    private func setupBindings() {
        locationManager.locationPermissionObservable
            .map { permissionStatus -> UIViewController in
                return permissionStatus == .authorizedWhenInUse ? UINavigationController(rootViewController: NearbyStationsViewController()) : LocationPromptViewController()
            }
            .bind(to: newChildViewControllerRequiredRelay)
            .disposed(by: disposeBag)
    }
}
