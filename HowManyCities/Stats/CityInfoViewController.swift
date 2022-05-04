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
  
  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView().autolayoutEnabled
    
    return scrollView
  }()
   
  private lazy var mapView: MKMapView = {
    let map = MKMapView().autolayoutEnabled
    map.mapType = .mutedStandard
    map.isPitchEnabled = false
    map.isScrollEnabled = false
    map.isMultipleTouchEnabled = false
    map.isZoomEnabled = false
    map.isRotateEnabled = false
    map.pointOfInterestFilter = .excludingAll
    
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
    label.numberOfLines = 1
    label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
    
    return label
  }()
  
  private lazy var populationLabel: UILabel = {
    let label = UILabel(text: "", style: UIFont.TextStyle.body)
    label.numberOfLines = 1
    
    return label
  }()
  
  private lazy var tempLabel: UILabel = {
    let label = UILabel(text: "", style: UIFont.TextStyle.body)
    label.numberOfLines = 0
    
    return label
  }()
  
  var city: City? {
    didSet {
      configure(with: city)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    
    infoStack.addArrangedSubview(cityLabel)
    infoStack.addArrangedSubview(populationLabel)
    infoStack.addArrangedSubview(tempLabel)
    
    scrollView.addSubview(mapView)
    scrollView.addSubview(infoStack)
    
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      mapView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      mapView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      mapView.heightAnchor.constraint(equalToConstant: 200),
      
      infoStack.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 8.0),
      infoStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8.0),
      infoStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8.0),
      infoStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      ])
    
    view.addSubview(scrollView)
    
    scrollView.pin(to: view.safeAreaLayoutGuide)
    
//    NSLayoutConstraint.activate([
//      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
//      scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//      scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
//      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//    ])
  }
  
  private func configure(with city: City?) {
    guard let city = city else {
      return
    }
    
    title = "\(city.countryFlag) \(city.nameWithStateAbbr)"
    navigationItem.title = "\(city.countryFlag) \(city.nameWithStateAbbr)"
    
    cityLabel.text = city.name
    
    let annotation = MKPointAnnotation()
    annotation.coordinate = city.coordinates
    mapView.addAnnotation(annotation)
    
    mapView.setRegion(.init(center: annotation.coordinate, span: .full), animated: true)
    
    populationLabel.text = "Population: \(city.population.commaSeparated)"
    
    
    if let statsProvider = statsProvider {
      tempLabel.text = "GUESSED CITIES NEARBY\n"
      statsProvider.guessedCities(near: city).prefix(10).forEach {
        if $0 == city { return }
        
        let distanceInKm = Int(round(city.distance(to: $0) / 1000.0))
        let bearing = city.bearing(to: $0)
        tempLabel.text! += "\($0.fullTitle) - \(distanceInKm.commaSeparated)km \(bearing.asArrow)\n"
      }
    }
//    tempLabel.text = """
//Name: \(city.name) \(city.capitalDesignation)
//State: \(city.state)
//Territory: \(city.territory)
//Country: \(city.country)
//Population: \(city.population)
//Coordinates: \(city.coordinates)
//Percent of people that guess this city: \(city.percentageOfSessions ?? 0.0)
//"""
  }
  
}
