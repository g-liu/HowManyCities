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
  
  private let viewModel: MapGuessViewModel
  
  private lazy var mapView: MKMapView = {
    let map = MKMapView().autolayoutEnabled
    map.mapType = .satellite
    map.isPitchEnabled = false
    map.isRotateEnabled = false
    map.setRegion(.init(center: .init(latitude: 0, longitude: 0), span: .init(latitudeDelta: 180, longitudeDelta: 360)), animated: true)
    map.setCameraZoomRange(.init(minCenterCoordinateDistance: 1000000), animated: true)
    map.removeAnnotations(map.annotations)
    map.pointOfInterestFilter = .excludingAll
    
    map.delegate = self
    
    map.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "MKAnnotationView")
    
    return map
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
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    viewModel = .init()
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    viewModel.delegate = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    view.backgroundColor = .systemBackground
    
    view.addSubview(mapView)
    view.addSubview(cityInputTextField)
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -64),
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      
      cityInputTextField.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 32),
      cityInputTextField.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -32),
      cityInputTextField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
    ])
    
    cityInputTextField.becomeFirstResponder()
  }
  
  private func submitGuess(_ guess: String) {
    viewModel.submitGuess(guess)
    
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
      self?.cityInputTextField.text = ""
      cities.forEach { city in
        self?.mapView.addOverlay(city.asCircle)
        
        self?.mapView.addAnnotation(CityAnnotation(city: city))
      }
      
      if let lastCity = cities.last {
        self?.mapView.setCenter(lastCity.coordinates, animated: true)
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
    }
    
    return MKOverlayRenderer(overlay: overlay)
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "MKAnnotationView", for: annotation)
    annotationView.canShowCallout = true
    return annotationView
  }
}
