//
//  StationDetailsViewModel.swift
//  iBike
//
//  Created by richard.reitzfeld on 7/1/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import RxSwift
import RxCocoa
import CoreLocation
import MapKit

final class StationDetailsViewModel: ViewModelProtocol, ReactiveCompatible {
    struct Input {}

    struct Output {
        let stationNameDriver: Driver<String>
        let stationRouteDriver: Driver<MKRoute?>
        let stationDriver: Driver<CitiBikeStation>
        let detailsDriver: Driver<[DetailsSectionType]>
    }

    enum DetailsSectionType {
        case header(title: String)
        case detail(viewModel: StationDetailViewModel)
        case directionStep(viewModel: DirectionStepViewModel)
    }

    // MARK: - Properties

    let input: Input = Input()
    let output: Output
    
    private let locationManager: LocationManager
    private let detailsRelay = BehaviorRelay<[DetailsSectionType]>(value: [])
    private var details: [DetailsSectionType] = [] {
        didSet {
            detailsRelay.accept(details)
        }
    }
    private let disposeBag = DisposeBag()
    fileprivate let directionsRequest = MKDirections.Request()
    private let routeRelay = BehaviorRelay<MKRoute?>(value: nil)

    // MARK: - Lifecycle

    init(station: CitiBikeStation, locationManager: LocationManager = .shared) {
        self.locationManager = locationManager

        output = Output(
            stationNameDriver: Driver.just(station.name),
            stationRouteDriver: routeRelay.asDriver(),
            stationDriver: Driver.just(station),
            detailsDriver: detailsRelay.asDriver()
        )

        configureDirectionRequest(for: station)
        configureIntialDetails(for: station)

        setupBindings()
    }

    // MARK: - Bindings

    private func setupBindings() {
        locationManager.currentLocationDriver
            .drive(rx.directionSource)
            .disposed(by: disposeBag)
    }

    // MARK: - Directions

    private func configureDirectionRequest(for station: CitiBikeStation) {
        directionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: station.location.coordinate))
        directionsRequest.transportType = .walking

        attemptDirectionsCalculation()
    }

    fileprivate func attemptDirectionsCalculation() {
        guard
            directionsRequest.source != nil,
            directionsRequest.destination != nil
            else { return }

        let directions = MKDirections(request: directionsRequest)

        directions.calculate { [weak self] response, error in
            guard
                let unwrappedResponse = response,
                let route = unwrappedResponse.routes.first
                else { return }

            self?.routeRelay.accept(route)
            self?.configureDirectionDetails(for: route)
        }
    }

    // MARK: - Details

    private func configureIntialDetails(for station: CitiBikeStation) {
        details = [
            .header(title: "Station Details:"),
            .detail(viewModel: StationDetailViewModel(detail: "Rental URLString: \(station.rentalURLString)")),
            .detail(viewModel: StationDetailViewModel(detail: "Latutude: \(station.latitude)")),
            .detail(viewModel: StationDetailViewModel(detail: "Longitude: \(station.longitude)")),
            .detail(viewModel: StationDetailViewModel(detail: "Station Type: \(station.stationType)")),
            .detail(viewModel: StationDetailViewModel(detail: "Rental Methods: \(station.rentalMethods.joined(separator: ", "))")),
            .detail(viewModel: StationDetailViewModel(detail: "Electric Bike Surcharge Waiver: \(station.electricBikeSurchargeWaiver)")),
            .detail(viewModel: StationDetailViewModel(detail: "Short Name: \(station.shortName)")),
            .detail(viewModel: StationDetailViewModel(detail: "Capacity: \(station.capacity)")),
            .detail(viewModel: StationDetailViewModel(detail: "Has Kiosk: \(station.hasKiosk)")),
            .detail(viewModel: StationDetailViewModel(detail: "External ID: \(station.externalId)")),
            .detail(viewModel: StationDetailViewModel(detail: "Station Name: \(station.name)")),
            .detail(viewModel: StationDetailViewModel(detail: "Has Key Dispensors: \(station.hasKeyDispenser)")),
            .detail(viewModel: StationDetailViewModel(detail: "Region ID: \(station.regionId)"))
        ]
    }

    private func configureDirectionDetails(for route: MKRoute) {
        guard route.steps.count > 1 else { return }
        let routeSteps: [DetailsSectionType] = route.steps.map { .directionStep(viewModel: DirectionStepViewModel(step: $0)) }
        let detailsToPrepend: [DetailsSectionType] = [.header(title: "Directions:")] + routeSteps
        details = detailsToPrepend + details
    }
}

extension Reactive where Base: StationDetailsViewModel {
    var directionSource: Binder<CLLocation?> {
        return Binder(base) { viewModel, location in
            guard let location = location else { return }
            viewModel.directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
            viewModel.attemptDirectionsCalculation()
        }
    }
}
