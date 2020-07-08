//
//  StationDetailsViewController.swift
//  iBike
//
//  Created by richard.reitzfeld on 7/1/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import MapKit

final class StationDetailsViewController: UIViewController {
    fileprivate enum Constants {
        static let mapViewHeight: CGFloat = 350.0
        static let mapViewDistanceSpan: Double = 500

        static let closeButtonText: String = "Close"
    }

    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private let viewModel: StationDetailsViewModel
    private let closeButton = UIBarButtonItem(title: Constants.closeButtonText, style: .plain, target: nil, action: nil)

    fileprivate let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        return mapView
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        tableView.bounces = false
        tableView.register(StationDetailTableViewCell.self, forCellReuseIdentifier: StationDetailTableViewCell.reuseIdentifier)
        tableView.register(DirectionStepTableViewCell.self, forCellReuseIdentifier: DirectionStepTableViewCell.reuseIdentifier)
        return tableView
    }()

    private lazy var tableViewDataSource: RxTableViewSectionedReloadDataSource<StationDetailsSectionModel> = {
        let dataSource = RxTableViewSectionedReloadDataSource<StationDetailsSectionModel>(configureCell: {[weak self] (dataSource, tableView, indexPath, sectionModelType) -> UITableViewCell in
            guard let self = self else { return UITableViewCell() }
            switch sectionModelType {
            case .header(let title):
                return self.headerTableViewCell(for: title)
            case .detail(let viewModel):
                return self.detailTableViewCell(for: viewModel)
            case .directionStep(let viewModel):
                return self.directionStepTableViewCell(for: viewModel)
            }
        })

        return dataSource
    }()

    // MARK: - Lifecycle

    init(station: CitiBikeStation) {
        viewModel = StationDetailsViewModel(station: station)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = closeButton
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

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.output.stationNameDriver
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)

        viewModel.output.stationRouteDriver
            .drive(rx.route)
            .disposed(by: disposeBag)

        viewModel.output.stationDriver
            .drive(rx.stationAnnotation)
            .disposed(by: disposeBag)

        viewModel.output.detailsDriver
            .map { [StationDetailsSectionModel(items: $0)] }
            .drive(tableView.rx.items(dataSource: tableViewDataSource))
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .bind(to: rx.dismissSelfFromPresentingViewControllerAnimated)
            .disposed(by: disposeBag)
    }

    // MARK: - Cell Helper

    private func headerTableViewCell(for title: String) -> UITableViewCell {
        let reuseIdentifier = "StationDetailsViewControllerHeaderCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)

        cell.textLabel?.text = title
        cell.textLabel?.font = .boldSystemFont(ofSize: 20.0)
        cell.selectionStyle = .none
        return cell
    }

    private func detailTableViewCell(for detailViewModel: StationDetailViewModel) -> StationDetailTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StationDetailTableViewCell.reuseIdentifier) as? StationDetailTableViewCell ?? StationDetailTableViewCell(style: .subtitle, reuseIdentifier: StationDetailTableViewCell.reuseIdentifier)

        cell.bind(to: detailViewModel)
        return cell
    }

    private func directionStepTableViewCell(for directionStepViewModel: DirectionStepViewModel) -> DirectionStepTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DirectionStepTableViewCell.reuseIdentifier) as? DirectionStepTableViewCell ?? DirectionStepTableViewCell(style: .subtitle, reuseIdentifier: DirectionStepTableViewCell.reuseIdentifier)

        cell.bind(to: directionStepViewModel)
        return cell
    }
}

extension Reactive where Base: StationDetailsViewController {
    var route: Binder<MKRoute?> {
        return Binder(base) { viewModel, route in
            guard let route = route else { return }
            viewModel.mapView.addOverlay(route.polyline)
            viewModel.mapView.setVisibleMapRect(route.polyline.boundingMapRect.insetBy(dx: -140.0, dy: -140.0), animated: false)
        }
    }

    var stationAnnotation: Binder<CitiBikeStation> {
        return Binder(base) { viewController, station in
            viewController.mapView.addAnnotation(station)
            let region = MKCoordinateRegion(center: station.coordinate, latitudinalMeters: StationDetailsViewController.Constants.mapViewDistanceSpan, longitudinalMeters: StationDetailsViewController.Constants.mapViewDistanceSpan)
            viewController.mapView.setRegion(region, animated: false)
        }
    }
}

extension StationDetailsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .citiBlueColor
        renderer.alpha = 0.8
        return renderer
    }
}
