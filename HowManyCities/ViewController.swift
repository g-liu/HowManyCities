//
//  ViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import UIKit
import MapKit

final class ViewController: UIViewController {
  
  private lazy var mapView: MKMapView = {
    let map = MKMapView().autolayoutEnabled
    map.mapType = .mutedStandard
    map.isPitchEnabled = false
    map.isRotateEnabled = false
    map.setRegion(.init(center: .init(latitude: 0, longitude: 0), span: .init(latitudeDelta: 180, longitudeDelta: 360)), animated: true)
    map.setCameraZoomRange(.init(minCenterCoordinateDistance: 1000000), animated: true)
    map.removeAnnotations(map.annotations)
    map.pointOfInterestFilter = .excludingAll
    
    map.delegate = self
    
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

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    view.backgroundColor = .systemBackground
    
    view.addSubview(mapView)
    view.addSubview(cityInputTextField)
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -64),
      mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      
      cityInputTextField.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 32),
      cityInputTextField.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -32),
      cityInputTextField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
    ])
    
    cityInputTextField.becomeFirstResponder()
  }

}

extension ViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard textField == cityInputTextField,
          let textInput = textField.text,
          !textInput.isEmpty else { return false }
    
    HMCAPIRequest.submitRequest(string: textInput) { [weak self] response in
      DispatchQueue.main.async { [weak self] in
        response?.cities.forEach { city in
//          let annotation = MKPointAnnotation()
//          annotation.coordinate = city.coordinates
//          self?.mapView.addAnnotation(annotation)
          
          self?.mapView.addOverlay(city.asCircle)
        }
        
        if let lastCity = response?.cities.last {
          self?.mapView.setCenter(lastCity.coordinates, animated: true)
        }
      }
    }
    textField.text = ""
    
    return false
  }
}

extension ViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let circle = overlay as? MKCircle {
      let circleRenderer = MKCircleRenderer(circle: circle)
      circleRenderer.fillColor = .systemRed.withAlphaComponent(0.5)
      circleRenderer.strokeColor = .systemFill
      
      return circleRenderer
    }
    
    return MKOverlayRenderer(overlay: overlay)
  }
}
