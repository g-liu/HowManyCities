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
  
//  private lazy var infoStack: UIStackView = {
//    let stackView = UIStackView().autolayoutEnabled
//    stackView.axis = .vertical
//    stackView.alignment = .leading
//    stackView.spacing = 8.0
//
//    return stackView
//  }()
  
  init(state: State, guessedCities: [City]) {
    self.state = state
    self.guessedCities = guessedCities.sorted(by: \.nameWithStateAbbr)
    
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
    let monoTextView = UITextView().autolayoutEnabled
    monoTextView.delegate = self
    
//    infoStack.addArrangedSubview(monoTextView)
    monoTextView.isScrollEnabled = false
    monoTextView.isEditable = false
    monoTextView.isSelectable = true
    monoTextView.textColor = .label
    monoTextView.linkTextAttributes = [.foregroundColor: UIColor.label]
    
    scrollView.addSubview(monoTextView)
    monoTextView.pin(to: scrollView, margins: .init(horizontal: 0, vertical: 12))
    monoTextView.widthAnchor.constraint(lessThanOrEqualTo: scrollView.widthAnchor).isActive = true
    
    view.addSubview(mapView)
    view.addSubview(scrollView)
    
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      mapView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
      mapView.heightAnchor.constraint(equalToConstant: 250),
      
      scrollView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 8.0),
      scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      scrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor)
    ])
    
    addCitiesToMap()
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 8
    let attributedText = NSAttributedString(attributedString: guessedCities.enumerated().map {
      let displayName = $1.nameWithStateAbbr.replacingOccurrences(of: " ", with: "\u{00a0}")
      return .init(string: displayName, attributes: [.link: URL(string: "takemeto://\($0)")!])
    }.joined(separator: "    "))
    
    monoTextView.attributedText = attributedText
    monoTextView.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
    
    let entireRange = NSRange(location: 0, length: monoTextView.textStorage.length)
    monoTextView.textStorage.addAttributes([.paragraphStyle: paragraphStyle], range: entireRange)
  }
  
  private func addCitiesToMap() {
    mapView.removeAnnotations(mapView.annotations)
    mapView.addAnnotations(guessedCities.map {
      let cityAnnotation = $0.asAnnotation
      
      cityAnnotation.title = $0.nameWithStateAbbr
      cityAnnotation.subtitle = "pop: \($0.population.commaSeparated)"
      
      return cityAnnotation
    })
    
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

extension StateInfoViewController: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    if URL.scheme == "takemeto",
       let index = Int(URL.host ?? "💩") {
      mapView.setRegion(MKCoordinateRegion(center: guessedCities[index].coordinates, span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
//      mapView.showAnnotations([mapView.annotations[index]], animated: true)
//      let entireRange = NSRange(location: 0, length: textView.textStorage.length)
      
      textView.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
      textView.textStorage.addAttributes([.font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize*1.5)], range: characterRange)
    }
    return false
  }
}
