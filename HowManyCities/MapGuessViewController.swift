//
//  MapGuessViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import UIKit
import MapKit
import SwifterSwift

final class MapGuessViewController: UIViewController {
  
  private var viewModel: MapGuessViewModel
  
  private lazy var mapView: MKMapView = {
    let map = MKMapView().autolayoutEnabled
    map.mapType = .satellite
    map.isPitchEnabled = false
    map.isRotateEnabled = false
    map.setRegion(.init(center: .init(latitude: 0, longitude: 0), span: .init(latitudeDelta: 180, longitudeDelta: 360)), animated: true)
    map.setCameraZoomRange(.init(minCenterCoordinateDistance: 1000000), animated: true)
    map.pointOfInterestFilter = .excludingAll
    
    map.delegate = self
    
    map.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "MKAnnotationView")
    
    return map
  }()
  
  private lazy var resetButton: UIButton = {
    let button = UIButton().autolayoutEnabled
    button.backgroundColor = .systemFill.withAlphaComponent(1.0)
    button.titleLabel?.textColor = .systemBackground
    button.setTitle("Reset", for: .normal)
    button.titleLabel?.textAlignment = .right
//    button.font = .systemFont(ofSize: UIFont.buttonFontSize)
    button.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
    
    return button
  }()
  
  private lazy var cityInputTextField: UITextField = {
    let textField = UITextField().autolayoutEnabled
    textField.delegate = self
    textField.layer.borderWidth = 1
    textField.layer.borderColor = UIColor.systemFill.cgColor
    textField.font = .systemFont(ofSize: 36)
    textField.textAlignment = .center
    
    textField.autocapitalizationType = .words
    textField.autocorrectionType = .no
  
    return textField
  }()
  
  private lazy var guessStats: MapGuessStatsBar = {
    .init().autolayoutEnabled
  }()
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    viewModel = .init()
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    viewModel.delegate = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    saveState()
  }
  
  @objc private func saveState() {
    print("SAVING STUFF")
    viewModel.saveGameState()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    NotificationCenter.default.addObserver(self, selector: #selector(saveState), name: UIApplication.willResignActiveNotification, object: nil)
    
    view.backgroundColor = .systemBackground
    
    view.addSubview(mapView)
    view.addSubview(resetButton)
    view.addSubview(guessStats)
    view.addSubview(cityInputTextField)
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -64),
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      
      resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -16),
      resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
      
      cityInputTextField.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 32),
      cityInputTextField.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -32),
      cityInputTextField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      
      guessStats.topAnchor.constraint(equalTo: mapView.bottomAnchor),
      guessStats.widthAnchor.constraint(equalTo: view.widthAnchor),
      guessStats.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ])
    
    cityInputTextField.becomeFirstResponder()
    
    updateMap(viewModel.model.guessedCities)
  }
  
  private func submitGuess(_ guess: String) {
    viewModel.submitGuess(guess)
  }
  
  private func resetMap() {
    mapView.removeOverlays(mapView.overlays)
    mapView.removeAnnotations(mapView.annotations)
  }
  
  private func updateMap(_ cities: Set<City>) {
    cities.forEach { city in
      mapView.addOverlay(city.asShape)
      
      mapView.addAnnotation(CityAnnotation(city: city))
    }
    
    guessStats.updatePopulationGuessed(viewModel.populationGuessed)
    guessStats.updateNumCitiesGuessed(viewModel.numCitiesGuessed)
    guessStats.updatePercentageTotalPopulation(viewModel.percentageTotalPopulationGuessed)
  }
  
  @objc private func didTapReset() {
    viewModel.resetState()
    resetMap()
    updateMap(viewModel.model.guessedCities)
    viewModel.saveGameState()
  }
}

extension MapGuessViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard textField == cityInputTextField else { return false }
    guard let textInput = textField.text,
          !textInput.isEmpty else {
            didReceiveError()
            return false
          }
    
    submitGuess(textInput)
    
    mapView.closeAllAnnotations()
    
    return false
  }
}

extension MapGuessViewController: MapGuessDelegate {
  func didReceiveCities(_ cities: [City]) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      self.cityInputTextField.text = ""
      self.updateMap(Set<City>(cities))
      
      if let lastCity = cities.last {
        self.mapView.setCenter(lastCity.coordinates, animated: true)
      }
    }
  }
  
  func didReceiveError() {
    cityInputTextField.shake()
  }

}

extension MapGuessViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let circle = overlay as? MKCircle {
      let circleRenderer = MKCircleRenderer(circle: circle)
      circleRenderer.fillColor = .systemRed.withAlphaComponent(0.5)
      circleRenderer.strokeColor = .systemFill
      
      return circleRenderer
    } else if let polygon = overlay as? MKPolygon {
      let polygonRenderer = MKPolygonRenderer(polygon: polygon)
      polygonRenderer.fillColor = .systemYellow.withAlphaComponent(0.7)
      polygonRenderer.strokeColor = .systemFill
      
      return polygonRenderer
    }
    
    return MKOverlayRenderer(overlay: overlay)
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "MKAnnotationView", for: annotation)
    annotationView.canShowCallout = true
    return annotationView
  }
}
