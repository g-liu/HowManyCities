//
//  StateInfoViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/6/22.
//

import UIKit
import MapKit

final class StateInfoViewController: UIViewController {
  
  let state: State
  let guessedCities: [City]
  
  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView().autolayoutEnabled
    
    return scrollView
  }()
  
  private lazy var mapView: MKMapView = {
    let map = MKMapView().autolayoutEnabled
    map.mapType = .satellite
    map.isPitchEnabled = false
    map.isScrollEnabled = true
    map.isMultipleTouchEnabled = false
    map.isZoomEnabled = true
    map.isRotateEnabled = false
    map.pointOfInterestFilter = .excludingAll
    
    // TODO: Should probably double check by making sure we have city annotations within.
    map.searchAndLocate(state.searchName) { region in
      guard let region = region else { return }
//      map.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: false)
    }
    
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
  
  init(state: State, guessedCities: [City]) {
    self.state = state
    self.guessedCities = guessedCities
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("NOOOOOOOOOO")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    
    title = state.nameWithFlag
    
    // TODO: 100% TEMP PLZ REFINE
    let monoLabel = UILabel(text: "", style: .body).autolayoutEnabled
    monoLabel.numberOfLines = 0
    
    infoStack.addArrangedSubview(monoLabel)
    
    scrollView.addSubview(mapView)
    scrollView.addSubview(infoStack)
    
    view.addSubview(scrollView)
    scrollView.pin(to: view.safeAreaLayoutGuide)
    
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
      scrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor)
    ])
    
    monoLabel.text = guessedCities.map(by: \.name).joined(separator: "; ")
    
    addCitiesToMap()
  }
  
  private func addCitiesToMap() {
    guessedCities.forEach {
      let cityAnnotation = $0.asAnnotation
      
      cityAnnotation.title = $0.nameWithStateAbbr
      cityAnnotation.subtitle = "pop: \($0.population.commaSeparated)"
      
      mapView.addAnnotation(cityAnnotation)
    }
    
//    mapView.showAnnotations(mapView.annotations, animated: false)
  }
  
}

extension StateInfoViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "something")
    annotationView.clusteringIdentifier = "yuhhhh"
    annotationView.markerTintColor = .systemRed
//    annotationView.displayPriority = .init(annotation.subtitle.count)
    return annotationView
  }
}
