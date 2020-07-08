//
//  NeabyStationsViewModel.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import RxSwift
import RxCocoa
import CoreLocation

class NearbyStationsViewModel: ViewModelProtocol, ReactiveCompatible {
    struct Input {
        let refreshButtonTappedObserver: AnyObserver<Void>
        let stationSelectedObserver: AnyObserver<CitiBikeStation>
    }

    struct Output {
        let stationsDriver: Driver<[NearbyStationViewModel]>
        let currentLocationDriver: Driver<CLLocation?>
        let presentStationDetailsSignal: Signal<UIViewController>
    }

    // MARK: - Properties

    let input: Input
    let output: Output
    
    private let citiBikeService: CitiBikeService
    private let locationManager: LocationManaging
    private let disposeBag = DisposeBag()
    private let stationsRelay = BehaviorRelay<[NearbyStationViewModel]>(value: [])
    private var stations: [NearbyStationViewModel] = []
    private let currentLocationRelay = BehaviorRelay<CLLocation?>(value: nil)
    fileprivate var currentLocation: CLLocation? {
        didSet {
            currentLocationRelay.accept(currentLocation)
        }
    }
    private let refreshButtonTappedRelay = PublishRelay<Void>()
    private let stationSelectedRelay = PublishRelay<CitiBikeStation>()
    private let presentStationDetailsRelay = PublishRelay<UIViewController>()

    // MARK: - Lifecycle

    init(citiBikeService: CitiBikeService = CitiBikeService(), locationManager: LocationManaging = LocationManager.shared) {
        self.citiBikeService = citiBikeService
        self.locationManager = locationManager

        output = Output(
            stationsDriver: stationsRelay.asDriver(),
            currentLocationDriver: currentLocationRelay.asDriver(),
            presentStationDetailsSignal: presentStationDetailsRelay.asSignal()
        )

        input = Input(
            refreshButtonTappedObserver: refreshButtonTappedRelay.asAnyObserver(),
            stationSelectedObserver: stationSelectedRelay.asAnyObserver()
        )

        getCitiBikeStations()
        getCurrentLocation()
        setupBindings()
    }

    // MARK: - Bindings

    private func setupBindings() {
        locationManager.currentLocationDriver
            .distinctUntilChanged()
            .drive(rx.location)
            .disposed(by: disposeBag)

        refreshButtonTappedRelay
            .subscribe(onNext: {[weak self] in
                self?.getCurrentLocation()
            }).disposed(by: disposeBag)

        stationSelectedRelay.map { station -> UIViewController in
            return UINavigationController(rootViewController: StationDetailsViewController(station: station))
        }
        .bind(to: presentStationDetailsRelay)
        .disposed(by: disposeBag)
    }

    // MARK: - Requests

    private func getCitiBikeStations() {
        citiBikeService.getCitiBikeStations()
            .subscribe(onSuccess: { [weak self] container in
                self?.stations = container.data.stations.map { NearbyStationViewModel(station: $0) }
                self?.sortStations()
            }) { error in
                print("Error getting citibike data: \(error)")
        }.disposed(by: disposeBag)
    }

    private func getCurrentLocation() {
        locationManager.requestCurrentLocationUpdate()
    }

    // MARK: - Sort

    fileprivate func sortStations() {
        guard
            stations.count > 0,
            let currentLocation = currentLocation
            else { return }

        stations.sort { (stationOne, stationTwo) -> Bool in
            return stationOne.station.location.distance(from: currentLocation) < stationTwo.station.location.distance(from: currentLocation)
        }

        stationsRelay.accept(stations)
    }
}

extension Reactive where Base: NearbyStationsViewModel {
    var location: Binder<CLLocation?> {
        return Binder(base) { viewModel, location in
            guard let location = location else { return }
            viewModel.currentLocation = location
            viewModel.sortStations()
        }
    }
}
