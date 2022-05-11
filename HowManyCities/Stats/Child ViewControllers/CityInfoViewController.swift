//
//  CityInfoViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/3/22.
//

import UIKit
import MapKit

final class CityInfoViewController: UIViewController {
  
  private var isShowingFullTitle: Bool = false {
    didSet {
      // TODO: Need to rework this for initialization
      let city = viewModel.city
      let cityName: String
      let upperDivisionText: String
      let numberOfLines = isShowingFullTitle ? 0 : 2
      
      // City name disambiguation is sometimes presented in parentheses
      // Ex. the city of Fugging (Upper Austria)
      // We want to render as Fugging instead.
      let upperDivisionSuffix = isShowingFullTitle ? city.upperDivisionTitle : city.upperDivisionTitleWithAbbr
      let regex = try! NSRegularExpression(pattern: #"\s+\((.+)\)"#)
      let matches = regex.matches(in: city.name, range: city.name.entireRange)
      if let match = matches.first?.range(at: 1),
         let substringRange = Range(match, in: city.name) {
        let upperDivisionPrefix = String(city.name[substringRange])
        upperDivisionText = [upperDivisionPrefix, upperDivisionSuffix].joined(separator: ", ")
        cityName = city.name.replacingOccurrences(of: #"\s+\(.+\)"#, with: "", options: .regularExpression)
      } else {
        cityName = city.name
        upperDivisionText = upperDivisionSuffix
      }
      
      if let countryFlag = city.countryFlag {
        title = "\(countryFlag) \(cityName)"
      } else {
        title = city.nameWithTerritoryAndCountry
      }
      
      let mas = NSMutableAttributedString(string: "\(cityName) ")
      if let capitalDesignation = city.capitalDesignation {
        mas.append(.init(string: capitalDesignation, attributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
                                                                  .foregroundColor: UIColor.systemYellow]))
      }
      mas.append(.init(string: "\(upperDivisionText)\(city.countryFlag ?? "")", attributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
                                                                                       .foregroundColor: UIColor.systemGray]))
      
      cityLabel.attributedText = mas
      cityLabel.numberOfLines = numberOfLines
    }
  }
  
  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView().autolayoutEnabled
    
    return scrollView
  }()
  
  private lazy var mapView: MKMapView = {
    let map = MKMapView().autolayoutEnabled
    map.mapType = .satellite
    map.isPitchEnabled = false
    map.isScrollEnabled = false
    map.isMultipleTouchEnabled = false
    map.isZoomEnabled = false
    map.isRotateEnabled = false
    map.pointOfInterestFilter = .excludingAll
    
    map.delegate = self
    
    return map
  }()
  
  private lazy var infoStack: UIStackView = {
    let stackView = UIStackView().autolayoutEnabled
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.spacing = 8.0
    
    return stackView
  }()
  
  private lazy var cityLabel: UILabel = {
    let label = UILabel(text: "", style: UIFont.TextStyle.largeTitle).autolayoutEnabled
    label.numberOfLines = 2
    label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCityLabel)))
    label.isUserInteractionEnabled = true
    
    return label
  }()
  
  private lazy var populationLabel: UILabel = {
    let label = UILabel(text: "", style: UIFont.TextStyle.body)
    label.numberOfLines = 1
    
    return label
  }()
  
  private lazy var percentGuessedLabel: UILabel = {
    let label = UILabel(text: "", style: UIFont.TextStyle.body)
    label.numberOfLines = 1
    
    return label
  }()
  
  private let viewModel: CityInfoViewModel
  
  init(city: City, statsProvider: GameStatisticsProvider?) {
    viewModel = .init(city: city, statsProvider: statsProvider)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    defer {
      isShowingFullTitle = false
    }
    
    view.backgroundColor = .systemBackground
    
    infoStack.insertArrangedSubview(cityLabel, at: 0)
    infoStack.insertArrangedSubview(populationLabel, at: 1)
    infoStack.insertArrangedSubview(percentGuessedLabel, at: 2)
    infoStack.setCustomSpacing(24.0, after: percentGuessedLabel)
    
    scrollView.addSubview(mapView)
    scrollView.addSubview(infoStack)
    
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      mapView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      mapView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      mapView.heightAnchor.constraint(equalToConstant: 250),
      
      infoStack.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 8.0),
      infoStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12.0),
      infoStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12.0),
      infoStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
    ])
    
    view.addSubview(scrollView)
    
    scrollView.pin(to: view.safeAreaLayoutGuide)
    
    configure(with: viewModel.city)
  }
  
  private func configure(with city: City) {
    let annotation = city.asAnnotation
    annotation.title = city.name
    mapView.addAnnotation(annotation)
    
    mapView.setRegion(.init(center: annotation.coordinate, span: .full), animated: true)
    
    populationLabel.text = "Population: \(city.population.commaSeparated)"
    
    if let percentGuessed = city.percentageOfSessions?.asPercentString {
      percentGuessedLabel.isHidden = false
      percentGuessedLabel.text = "\(percentGuessed) of people guessed this city"
    } else {
      percentGuessedLabel.isHidden = true
    }
    
    if let nearbyCityList = viewModel.nearbyCityList, !nearbyCityList.isEmpty {
      let nearbyTitle = UILabel(text: "Nearby guessed cities:", style: .title2).autolayoutEnabled
      nearbyTitle.isUserInteractionEnabled = true
      nearbyTitle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapShowAllNearbyCities)))
      infoStack.addArrangedSubview(nearbyTitle)
      
      nearbyCityList.enumerated().forEach {
        let nearbyCityLabel = UILabel(text: "", style: .body).autolayoutEnabled
        nearbyCityLabel.attributedText = $1

        nearbyCityLabel.tag = $0

        nearbyCityLabel.isUserInteractionEnabled = true
        nearbyCityLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapNearbyCity)))

        infoStack.addArrangedSubview(nearbyCityLabel)
        infoStack.setCustomSpacing(4.0, after: nearbyCityLabel)
      }
    } else if let nearestCityText = viewModel.nearestCityText {
      let nearbyTitle = UILabel(text: "No nearby guessed cities", style: .title2).autolayoutEnabled
      infoStack.addArrangedSubview(nearbyTitle)
      
      let nearbyCityLabel = UILabel().autolayoutEnabled
      nearbyCityLabel.numberOfLines = 0

      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showNearestCity))
//      tapGestureRecognizer.data = closestCity
      nearbyCityLabel.addGestureRecognizer(tapGestureRecognizer)
      nearbyCityLabel.isUserInteractionEnabled = true
      nearbyCityLabel.attributedText = nearestCityText

      infoStack.addArrangedSubview(nearbyCityLabel)
    }
  }
  
  @objc private func didTapCityLabel() {
    isShowingFullTitle = !isShowingFullTitle
  }
  
  @objc private func didTapShowAllNearbyCities(_ sender: Any) {
    guard let annotations = viewModel.nearbyCityAnnotations else { return }
    
    mapView.removeAnnotations(mapView.annotations.filter { $0.coordinate != viewModel.city.coordinates })
    mapView.removeOverlays(mapView.overlays)
    
    annotations.forEach {
      mapView.addAnnotation($0)
      
      let line = MKPolyline(coordinates: [viewModel.city.coordinates, $0.coordinate])
      mapView.addOverlay(line)
    }
    
    mapView.showAnnotations(mapView.annotations, animated: true)
  }
  
  @objc private func didTapNearbyCity(_ sender: Any) {
    guard let label = (sender as? UIGestureRecognizer)?.view as? UILabel else { return }
    let tag = label.tag
//    guard let nearbyCity = viewModel.getCity(tag) else { return }
    guard let annotations = viewModel.nearbyCityAnnotations,
          annotations.isIndexValid(tag) else { return }
    
    // put this on the map
    mapView.removeAnnotations(mapView.annotations.filter { $0.coordinate != viewModel.city.coordinates })
    mapView.removeOverlays(mapView.overlays)
    
    let annotation = annotations[tag]
    mapView.addAnnotation(annotation)
    let line = MKPolyline(coordinates: [viewModel.city.coordinates, annotation.coordinate])
    mapView.addOverlay(line)
    
    mapView.showAnnotations(mapView.annotations, animated: true)
  }
  
  @objc private func showNearestCity(_ sender: Any) {
    guard let nearestCityAnnotation = viewModel.nearestCityAnnotation else { return }
    
    mapView.removeAnnotations(mapView.annotations.filter { $0.coordinate != viewModel.city.coordinates })
    mapView.removeOverlays(mapView.overlays)
    
    mapView.addAnnotation(nearestCityAnnotation)
    
    mapView.showAnnotations(mapView.annotations, animated: true)
  }
  
}

extension CityInfoViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "something")
    if annotation.coordinate == viewModel.city.coordinates {
      annotationView.markerTintColor = .systemPurple
    } else {
      annotationView.markerTintColor = .systemRed
    }
    annotationView.displayPriority = .required
    return annotationView
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let polyline = overlay as? MKPolyline {
      let polylineRenderer = MKPolylineRenderer(overlay: polyline)
      polylineRenderer.strokeColor = .systemRed
      polylineRenderer.lineWidth = 2
      polylineRenderer.lineDashPattern = [2, 4]
      return polylineRenderer
    }
    return MKOverlayRenderer(overlay: overlay)
  }
}
