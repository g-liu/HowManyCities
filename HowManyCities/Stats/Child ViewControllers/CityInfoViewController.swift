//
//  CityInfoViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/3/22.
//

import UIKit
import MapKit

class CityInfoViewController: UIViewController {
  weak var statsProvider: GameStatisticsProvider?
  
  private var isShowingFullTitle: Bool = false {
    didSet {
      guard let city = city else { return }
      
      let cityName: String
      let upperDivisionText: String
      let numberOfLines = isShowingFullTitle ? 0 : 2
      
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
  
  private let nearbyThreshold: Double = 500_000 // in meters
  
  var city: City? {
    didSet {
      if let city = city, let statsProvider = statsProvider {
        nearbyCities = statsProvider.guessedCities(near: city).prefix(10).filter { city.distance(to: $0) < nearbyThreshold }
      } else {
        nearbyCities = []
      }
      configure(with: city)
    }
  }
  
  private var nearbyCities: [City] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
      mapView.heightAnchor.constraint(equalToConstant: 200),
      
      infoStack.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 8.0),
      infoStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12.0),
      infoStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12.0),
      infoStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
    ])
    
    view.addSubview(scrollView)
    
    scrollView.pin(to: view.safeAreaLayoutGuide)
  }
  
  private func configure(with city: City?) {
    guard let city = city else {
      return
    }
    
    defer {
      isShowingFullTitle = false
    }
    
    let annotation = city.asAnnotation
    mapView.addAnnotation(annotation)
    
    mapView.setRegion(.init(center: annotation.coordinate, span: .full), animated: true)
    
    populationLabel.text = "Population: \(city.population.commaSeparated)"
    
    if let percentGuessed = city.percentageOfSessions?.asPercentString {
      percentGuessedLabel.isHidden = false
      percentGuessedLabel.text = "\(percentGuessed) of people guessed this city"
    } else {
      percentGuessedLabel.isHidden = true
    }
    
    if !nearbyCities.isEmpty {
      let nearbyTitle = UILabel(text: "Nearby guessed cities:", style: .title2).autolayoutEnabled
      nearbyTitle.isUserInteractionEnabled = true
      nearbyTitle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapShowAllNearbyCities)))
      infoStack.addArrangedSubview(nearbyTitle)
      
      nearbyCities.enumerated().forEach {
        if $1 == city { return }
        
        let distanceInKm = city.distance(to: $1) / 1000.0
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if distanceInKm > 0 {
          numberFormatter.maximumFractionDigits = Int(max(0, ceil(-log10(distanceInKm) + 1.0)))
        } else {
          numberFormatter.maximumFractionDigits = 0
        }
        let distanceInKmString = numberFormatter.string(from: distanceInKm as NSNumber) ?? String(distanceInKm)
        
        let bearing = city.bearing(to: $1)
        
        let nearbyCityLabel = UILabel(text: "", style: .body).autolayoutEnabled
        let cityTitle = name(for: $1, comparedTo: city)
        let mas = NSMutableAttributedString(string: "\(cityTitle)  ")
        mas.append(.init(string: "\(distanceInKmString)km \(bearing.asArrow)", attributes: [.foregroundColor: UIColor.systemGray]))
        nearbyCityLabel.attributedText = mas
        
        nearbyCityLabel.tag = $0
        
        nearbyCityLabel.isUserInteractionEnabled = true
        nearbyCityLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapNearbyCity)))
        
        infoStack.addArrangedSubview(nearbyCityLabel)
        infoStack.setCustomSpacing(4.0, after: nearbyCityLabel)
      }
    } else {
      let nearbyTitle = UILabel(text: "No nearby guessed cities", style: .title2).autolayoutEnabled
      infoStack.addArrangedSubview(nearbyTitle)
      if let closestCity = statsProvider?.nearestCity(to: city) {
        let cityName = name(for: closestCity, comparedTo: city)
        let distance = Int(round(city.distance(to: closestCity) / 1000.0))
        let bearing = city.bearing(to: closestCity)
        let nearbyCityLabel = UILabel().autolayoutEnabled
        nearbyCityLabel.numberOfLines = 0
        let mas = NSMutableAttributedString(string: "The closest city you guessed is ")
        mas.append(.init(string: cityName, attributes: [.font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)]))
        mas.append(.init(", which is "))
        mas.append(.init(string: "\(distance.commaSeparated)km \(bearing.asArrow)", attributes: [.foregroundColor: UIColor.systemGray]))
        mas.append(.init(string: " away."))
        
        let tapGestureRecognizer = UIParameterizedTapGestureRecognizer(target: self, action: #selector(showNearestCity))
        tapGestureRecognizer.data = closestCity
        nearbyCityLabel.addGestureRecognizer(tapGestureRecognizer)
        nearbyCityLabel.isUserInteractionEnabled = true
        nearbyCityLabel.attributedText = mas
                                                        
        infoStack.addArrangedSubview(nearbyCityLabel)
      }
    }
  }
  
  private func name(for otherCity: City, comparedTo city: City) -> String {
    if city.country != otherCity.country {
      return otherCity.fullTitle
    } else if city.state != otherCity.state {
      return otherCity.nameWithStateAbbr
    }
    return otherCity.name
  }
  
  @objc private func didTapCityLabel() {
    isShowingFullTitle = !isShowingFullTitle
  }
  
  @objc private func didTapShowAllNearbyCities(_ sender: Any) {
    guard let city = city, !nearbyCities.isEmpty else { return }
    
    mapView.removeAnnotations(mapView.annotations.filter { $0.coordinate != city.coordinates })
    mapView.removeOverlays(mapView.overlays)
    
    nearbyCities.forEach {
      addNearbyCityAnnotation($0)
    }
    
//    mapView.zoom(to: [city.coordinates] + nearbyCities.map { $0.coordinates }, meter: 1500000, edgePadding: .init(inset: 25.0), animated: false)
    mapView.showAnnotations(mapView.annotations, animated: true)
  }
  
  @objc private func didTapNearbyCity(_ sender: Any) {
    guard let label = (sender as? UIGestureRecognizer)?.view as? UILabel else { return }
    let tag = label.tag
    guard let city = city, tag >= 0, tag < nearbyCities.count else { return }
    
    // put this on the map
    mapView.removeAnnotations(mapView.annotations.filter { $0.coordinate != city.coordinates })
    mapView.removeOverlays(mapView.overlays)
    
    let nearbyCity = nearbyCities[tag]
    addNearbyCityAnnotation(nearbyCity)
    
//    mapView.zoom(to: [city.coordinates, nearbyCity.coordinates], meter: 1500000, edgePadding: .init(inset: 75.0), animated: false)
    mapView.showAnnotations(mapView.annotations, animated: true)
  }
  
  @objc private func showNearestCity(_ sender: Any) {
    guard let city = city,
          let nearestCity = (sender as? UIParameterizedTapGestureRecognizer)?.data as? City else { return }
    
    mapView.removeAnnotations(mapView.annotations.filter { $0.coordinate != city.coordinates })
    mapView.removeOverlays(mapView.overlays)
    
    addNearbyCityAnnotation(nearestCity)
    
    mapView.showAnnotations(mapView.annotations, animated: true)
  }
  
  private func addNearbyCityAnnotation(_ nearbyCity: City) {
    guard let city = city else { return }
    mapView.addAnnotation(nearbyCity.asAnnotation)
    
    let line = MKPolyline(coordinates: [city.coordinates, nearbyCity.coordinates])
    mapView.addOverlay(line)
  }
  
}

extension CityInfoViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "something")
    if annotation.coordinate == city?.coordinates {
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
      polylineRenderer.strokeColor = .systemFill
      polylineRenderer.lineWidth = 1
      polylineRenderer.lineDashPattern = [2, 4]
      return polylineRenderer
    }
    return MKOverlayRenderer(overlay: overlay)
  }
}
