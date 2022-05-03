//
//  CityInfoViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/3/22.
//

import UIKit
import MapKit

class CityInfoViewController: UIViewController {
   
  private lazy var mapView: MKMapView = {
    let map = MKMapView().autolayoutEnabled
    map.mapType = .mutedStandard
    map.isPitchEnabled = false
    map.isScrollEnabled = false
    map.isMultipleTouchEnabled = false
    map.isZoomEnabled = false
    map.isRotateEnabled = false
    map.pointOfInterestFilter = .excludingAll
    map.setRegion(.full, animated: true)
    
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
    
    view.addSubview(mapView)
    view.addSubview(infoStack)
    
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      mapView.heightAnchor.constraint(equalToConstant: 200),
      
      infoStack.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 8.0),
      infoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.0),
      infoStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8.0),
      infoStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
      ])
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
