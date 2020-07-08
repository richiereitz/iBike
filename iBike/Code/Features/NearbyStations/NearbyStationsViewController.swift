//
//  NearbyStationsViewController.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import MapKit

final class NearbyStationsViewController: UIViewController {
    fileprivate enum Constants {
        static let mapViewHeight: CGFloat = 350.0
        static let mapViewDistanceSpan: Double = 500

        static let refreshButtonText: String = "Refresh"
    }

    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private let viewModel = NearbyStationsViewModel()
    private let refreshButton = UIBarButtonItem(title: Constants.refreshButtonText, style: .plain, target: nil, action: nil)

    fileprivate let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.mapType = .mutedStandard
        return mapView
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        tableView.register(NearbyStationTableViewCell.self, forCellReuseIdentifier: NearbyStationTableViewCell.reuseIdentifier)
        return tableView
    }()

    private lazy var tableViewDataSource: RxTableViewSectionedReloadDataSource<NearbyStationSectionModel> = {
        let dataSource = RxTableViewSectionedReloadDataSource<NearbyStationSectionModel>(configureCell: {[weak self] (dataSource, tableView, indexPath, station) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: NearbyStationTableViewCell.reuseIdentifier) as? NearbyStationTableViewCell ?? NearbyStationTableViewCell(style: .subtitle, reuseIdentifier: NearbyStationTableViewCell.reuseIdentifier)

            cell.bind(to: station)
            return cell
        })

        return dataSource
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Nearby Stations"
        navigationItem.rightBarButtonItem = refreshButton

        view.backgroundColor = .systemBackground

        mapView.delegate = self
        view.addSubview(mapView)
        view.addSubview(tableView)

        setupConstraints()

        /*
        Dispatching to main to avoid a known RxDataSurces issue:
        https://github.com/RxSwiftCommunity/RxDataSources/issues/331
         */
        DispatchQueue.main.async { [weak self] in
            self?.setupBindings()
        }
    }

    // MARK: - Layout

    private func setupConstraints() {
        mapView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Constants.mapViewHeight)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    private func setupBindings() {
        refreshButton.rx.tap
            .bind(to: viewModel.input.refreshButtonTappedObserver)
            .disposed(by: disposeBag)
        
        viewModel.output.stationsDriver
            .map { [NearbyStationSectionModel(items: $0)] }
            .drive(tableView.rx.items(dataSource: tableViewDataSource))
            .disposed(by: disposeBag)

        viewModel.output.stationsDriver
            .drive(rx.mapAnnotations)
            .disposed(by: disposeBag)

        viewModel.output.currentLocationDriver
            .drive(rx.mapRegion)
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(NearbyStationViewModel.self)
            .map { $0.station }
            .bind(to: viewModel.input.stationSelectedObserver)
            .disposed(by: disposeBag)

        viewModel.output.presentStationDetailsSignal
            .emit(to: rx.presentModalViewControllerAnimated)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: NearbyStationsViewController {
    var mapRegion: Binder<CLLocation?> {
        return Binder(base) { viewController, location in
            guard let location = location else { return }
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: NearbyStationsViewController.Constants.mapViewDistanceSpan, longitudinalMeters: NearbyStationsViewController.Constants.mapViewDistanceSpan)
            viewController.mapView.setRegion(region, animated: false)

            /*
             Setting this purely for UI purposes -- However, it presents some questions about how best to handle the user's location, as
             the LocationManager is currently using a one-off location update in order to reduce sorting frequency to only occur via
             user-initiated events, while the mapView's user location is dynamically updated as the device moves around.

             This presents a disparity in the UI between the cells shown in the tableView and the annotations on the mapView -- the
             annotations will be re calculated based on the user's current location on the map any time a pin is pressed, and the cells
             will only be re calculated when the user hits the refresh button. There may be instances where these values do not align if
             the user is moving and checking the app as they do so. With more time I would try to find a better solve for this, such as
             dynamically updating the location in the LocaitonManager, but only firing an "update" if the distance between the fired
             location crosses a certain threshold. For now it's just to make the UI look pretty on the initial load.
             */
            viewController.mapView.showsUserLocation = true
        }
    }

    var mapAnnotations: Binder<[NearbyStationViewModel]> {
        return Binder(base) { viewController, stations in
            stations.forEach {
                viewController.mapView.addAnnotation($0.station)
            }
        }
    }
}

extension NearbyStationsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKUserLocation == false else { return nil }

        let annotationReuseIdentifier = "annotationReuseIdentifier"
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationReuseIdentifier)
        annotationView.pinTintColor = .citiBlueColor
        annotationView.canShowCallout = true
        if let userLocation = mapView.userLocation.location {
            let distanceLabel = UILabel()
            distanceLabel.textColor = .gray
            distanceLabel.font = .systemFont(ofSize: 14.0, weight: .light)
            let distance =  CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude).distanceInMiles(from: userLocation)
            distanceLabel.text = String(format:"%.2f miles away", distance)
            annotationView.detailCalloutAccessoryView = distanceLabel
        }

        let button = UIButton(type: .detailDisclosure)
        button.tintColor = .white
        button.frame = CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0)
        button.backgroundColor = .citiBlueColor
        annotationView.rightCalloutAccessoryView = button

        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let citiBikeStation = view.annotation as? CitiBikeStation else { return }
        viewModel.input.stationSelectedObserver.onNext(citiBikeStation)
    }
}
