//
//  LocationPromptViewModel.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import RxSwift
import RxCocoa

final class LocationPromptViewModel: ViewModelProtocol, ReactiveCompatible {
    struct Input {
        let useMyLocationButtonTappedObserver: AnyObserver<Void>
    }

    struct Output {}

    // MARK: - Properties

    let input: Input
    let output: Output = Output()

    private let disposeBag = DisposeBag()

    fileprivate let locationManager: LocationManaging

    private let useMyLocationButtonTappedRelay = PublishRelay<Void>()

    // MARK: - Lifecycle

    init(locationManager: LocationManaging = LocationManager.shared) {
        self.locationManager = locationManager

        input = Input(
            useMyLocationButtonTappedObserver: useMyLocationButtonTappedRelay.asAnyObserver()
        )

        setupBindings()
    }

    // MARK: - Bindings

    private func setupBindings() {
        useMyLocationButtonTappedRelay
            .bind(to: rx.requestLocationPermissions)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: LocationPromptViewModel {
    var requestLocationPermissions: Binder<Void> {
        return Binder(base) { viewModel, _ in
            guard viewModel.locationManager.currentLocationPermissions == .notDetermined else {
                // With more time would present an alert with how to change permissions in settings. Just sending the user there for this version.
                if let settingsURL = URL(string:UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
                return
            }
            viewModel.locationManager.requestWhenInUse()
        }
    }
}


