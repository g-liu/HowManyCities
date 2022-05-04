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
      
      let upperDivisionText = isShowingFullTitle ? city.upperDivisionTitle : city.upperDivisionTitleWithAbbr
      let numberOfLines = isShowingFullTitle ? 0 : 2
      
      let mas = NSMutableAttributedString(string: "\(city.name) ")
      if let capitalDesignation = city.capitalDesignation {
        mas.append(.init(string: capitalDesignation, attributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
                                                                  .foregroundColor: UIColor.systemYellow]))
      }
      mas.append(.init(string: "\(upperDivisionText)\(city.countryFlag)", attributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
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
  
  var city: City? {
    didSet {
      if let city = city, let statsProvider = statsProvider {
        nearbyCities = statsProvider.guessedCities(near: city).prefix(10).asArray
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
      infoStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8.0),
      infoStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8.0),
      infoStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      ])
    
    view.addSubview(scrollView)
    
    scrollView.pin(to: view.safeAreaLayoutGuide)
  }
  
  private func configure(with city: City?) {
    guard let city = city else {
      return
    }
    
    title = "\(city.countryFlag) \(city.nameWithStateAbbr)"
    navigationItem.title = "\(city.countryFlag) \(city.nameWithStateAbbr)"
    
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
    
    if let statsProvider = statsProvider {
      let nearbyTitle = UILabel(text: "Nearby guessed cities:", style: .title2).autolayoutEnabled
      infoStack.addArrangedSubview(nearbyTitle)
      
      nearbyCities.enumerated().forEach {
        if $1 == city { return }
        
        let distanceInKm = Int(round(city.distance(to: $1) / 1000.0))
        let bearing = city.bearing(to: $1)
        
        let nearbyCityLabel = UILabel(text: "", style: .body).autolayoutEnabled
        let cityTitle: String
        if city.country != $1.country {
          cityTitle = $1.fullTitle
        } else if city.state != $1.state {
          cityTitle = $1.nameWithStateAbbr
        } else {
          cityTitle = $1.name
        }
        let mas = NSMutableAttributedString(string: "\(cityTitle) ")
        mas.append(.init(string: "\(distanceInKm.commaSeparated)km ", attributes: [.foregroundColor: UIColor.systemGray]))
        mas.append(.init(string: "\(bearing.asArrow)", attributes: [.font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)]))
        nearbyCityLabel.attributedText = mas
        
        nearbyCityLabel.tag = $0
        
        nearbyCityLabel.isUserInteractionEnabled = true
        nearbyCityLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapNearbyCity)))
        
        infoStack.addArrangedSubview(nearbyCityLabel)
        infoStack.setCustomSpacing(4.0, after: nearbyCityLabel)
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
  
  @objc private func didTapCityLabel() {
    isShowingFullTitle = !isShowingFullTitle
  }
  
  @objc private func didTapNearbyCity(_ sender: Any) {
    guard let label = (sender as? UIGestureRecognizer)?.view as? UILabel else { return }
    let tag = label.tag
    guard let city = city, tag >= 0, tag < nearbyCities.count else { return }
    
    // put this on the map
    mapView.removeAnnotations(mapView.annotations)
    
    mapView.addAnnotation(city.asAnnotation)
    mapView.addAnnotation(nearbyCities[tag].asAnnotation)
  }
  
}
