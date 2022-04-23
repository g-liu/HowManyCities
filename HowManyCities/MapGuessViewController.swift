//
//  MapGuessViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import UIKit
import MapKit
import SwifterSwift
import MapCache

final class MapGuessViewController: UIViewController {
  
  private var viewModel: MapGuessViewModel
  
  private lazy var mapView: MKMapView = {
    let map = MKMapView().autolayoutEnabled
    map.mapType = .satellite
    map.isPitchEnabled = false
    map.isRotateEnabled = false
//    map.setRegion(.init(center: .init(latitude: 0, longitude: 0), span: .init(latitudeDelta: 180, longitudeDelta: 360)), animated: true)
    map.setRegion(viewModel.lastRegion, animated: true)
    map.setCameraZoomRange(.init(minCenterCoordinateDistance: 100000), animated: true)
    map.pointOfInterestFilter = .excludingAll
    
    map.delegate = self
    
    map.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "MKAnnotationView")
    
    return map
  }()
  
  private lazy var resetButton: UIButton = {
    var cfg = UIButton.Configuration.gray()
    cfg.cornerStyle = .fixed
    cfg.baseForegroundColor = .label
    cfg.baseBackgroundColor = .systemFill.withAlphaComponent(1.0)
    cfg.buttonSize = .medium
    cfg.contentInsets = .init(top: 4, leading: 8, bottom: 4, trailing: 8)
  
    let button = UIButton(configuration: cfg).autolayoutEnabled
    button.setTitle("Reset", for: .normal)
    button.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
    
    return button
  }()
  
  private lazy var finishButton: UIButton = {
    var cfg = UIButton.Configuration.filled()
    cfg.cornerStyle = .fixed
    cfg.baseBackgroundColor = .systemGreen
    cfg.baseForegroundColor = .label
    cfg.buttonSize = .medium
    cfg.contentInsets = .init(top: 4, leading: 8, bottom: 4, trailing: 8)
    
    let button = UIButton(configuration: cfg).autolayoutEnabled
    button.setTitle("Finish", for: .normal)
    button.addTarget(self, action: #selector(didTapFinish), for: .touchUpInside)
    
    return button
  }()
  
  private lazy var guessStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [cityInputTextField, countryDropdownButton]).autolayoutEnabled
    stackView.axis = .horizontal
    stackView.spacing = 8.0
    stackView.alignment = .center
    stackView.distribution = .fill
    
    return stackView
  }()
  
  private lazy var cityInputTextField: UITextField = {
    let textField = UITextField().autolayoutEnabled
    textField.delegate = self
    textField.layer.borderWidth = 1
    textField.layer.borderColor = UIColor.systemFill.cgColor
    textField.font = .systemFont(ofSize: 36)
    textField.textAlignment = .center
    textField.clearButtonMode = .whileEditing
    
    textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
    
    textField.autocapitalizationType = .words
    textField.autocorrectionType = .no
  
    return textField
  }()
  
  private lazy var countryDropdownButton: UIButton = {
    var cfg = UIButton.Configuration.bordered()
    cfg.baseForegroundColor = .label
    
    let button = UIButton(configuration: cfg).autolayoutEnabled
    button.setTitle("🌎 ▼", for: .normal)
    button.addTarget(self, action: #selector(didTapCountryDropdown), for: .touchUpInside)
    button.contentVerticalAlignment = .center
    button.titleLabel?.numberOfLines = 1
    
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
    
    return button
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
    view.addSubview(finishButton)
    view.addSubview(guessStats)
    view.addSubview(guessStackView)
    
//    view.addSubview(cityInputTextField)
//    view.addSubview(countryDropdownButton)
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -64),
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      
      resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -16),
      resetButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 16),
      
      finishButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -16),
      finishButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
      
//      cityInputTextField.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 32),
//      cityInputTextField.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor, constant: -32).with(priority: .required),
//      cityInputTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
//      countryDropdownButton.leadingAnchor.constraint(equalTo: cityInputTextField.trailingAnchor, constant: 16),
//      countryDropdownButton.centerYAnchor.constraint(equalTo: cityInputTextField.centerYAnchor),
//      countryDropdownButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
      
      guessStats.topAnchor.constraint(equalTo: mapView.bottomAnchor),
      guessStats.widthAnchor.constraint(equalTo: view.widthAnchor),
      guessStats.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      guessStackView.topAnchor.constraint(equalTo: guessStats.bottomAnchor, constant: 16),
      guessStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      guessStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
    ])
    
    cityInputTextField.becomeFirstResponder()
    
    addCustomTileOverlay()
    updateMap(viewModel.guessedCities)
  }
  
  private func submitGuess(_ guess: String) {
    viewModel.submitGuess(guess)
  }
  
  @objc private func didTapCountryDropdown(_ sender: UIButton) {
    // TODO: impl
//    let alert = UIAlertController(title: "Select a location", message: nil, preferredStyle: .actionSheet)
//
//    let selector = CountrySelector().autolayoutEnabled
//    selector.delegate = viewModel
//    selector.dataSource = viewModel
//    alert.view.addSubview(selector)
//    alert.view.translatesAutoresizingMaskIntoConstraints = false
//    selector.pin(to: alert.view.safeAreaLayoutGuide, margins: .init(top: 0, left: 0, bottom: 48, right: 0))
//    NSLayoutConstraint.activate([
//      alert.view.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.height / 2.0),
//      ])
//    selector.selectRow(viewModel.selectedRow, inComponent: 0, animated: false)
//
//    alert.addAction(title: "Select", style: .default, isEnabled: true)
//
//    present(alert, animated: true)
    let searchController = CountrySearchController()
    searchController.countryDelegate = viewModel
    present(searchController, animated: true)
  }
  
  private func resetMap() {
    mapView.removeOverlays(mapView.overlays.filter {
      type(of: $0) != MKTileOverlay.self && type(of: $0) != CachedTileOverlay.self
    })
    mapView.removeAnnotations(mapView.annotations)
//    addCustomTileOverlay()
  }
  
  private func updateMap(_ cities: Set<City>) {
    cities.forEach { city in
      mapView.addOverlay(city.asShape, level: .aboveLabels)
      
      mapView.addAnnotation(CityAnnotation(city: city))
    }
    
    guessStats.updatePopulationGuessed(viewModel.populationGuessed)
    guessStats.updateNumCitiesGuessed(viewModel.numCitiesGuessed)
    guessStats.updatePercentageTotalPopulation(viewModel.percentageTotalPopulationGuessed)
  }
  
  private func addCustomTileOverlay() {
    // TODO: Verify w/cache
    
//    let interfaceMode = traitCollection.userInterfaceStyle == .dark ? "dark" : "light"
////    let template = "https://{s}.basemaps.cartocdn.com/\(interfaceMode)_nolabels/{z}/{x}/{y}@2x.png"
////    let template = Bundle.main.resourceURL?.appendingPathComponent("\(interfaceMode)-{z}_{x}_{y}.png").path
//    let bundleUrl = Bundle.main.url(forResource: "dummy", withExtension: "png")
//    let template = bundleUrl?.deletingLastPathComponent().appendingPathComponent("\(interfaceMode)-{z}_{x}_{y}.png").absoluteString.removingPercentEncoding
//
//
//    let overlay = MKTileOverlay(urlTemplate: template)
//    overlay.canReplaceMapContent = true
//    mapView.addOverlay(overlay, level: .aboveLabels)
     
     
    let interfaceMode = traitCollection.userInterfaceStyle == .dark ? "dark" : "light"
    let template = "https://{s}.basemaps.cartocdn.com/\(interfaceMode)_nolabels/{z}/{x}/{y}.png"
    let config = MapCacheConfig(withUrlTemplate: template)
//    let config = MapCacheConfig(withUrlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png")

    let mapCache = MapCache(withConfig: config)
    print("STORING ALL YOUR SHIT AT \(mapCache.diskCache.path)")
    mapView.useCache(mapCache)
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.resetMap()
        self.mapView.removeOverlays(self.mapView.overlays.filter { type(of: $0) == MKTileOverlay.self || type(of: $0) == CachedTileOverlay.self })
        self.addCustomTileOverlay()
        self.updateMap(self.viewModel.guessedCities)
      }
    }
  }
  
  @objc private func didTapReset() {
    let confirmResetController = UIAlertController(title: "Clear everything?", message: "Are you sure you want to clear your game? Once you do, there's no way to get your cities back.", preferredStyle: .alert)
    confirmResetController.addAction(.init(title: "Yes", style: .destructive, handler: { _ in
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.didConfirmReset()
      }
    }))
    confirmResetController.addAction(.init(title: "Never mind", style: .cancel))
    
    present(confirmResetController, animated: true)
  }
  
  private func didConfirmReset() {
    viewModel.resetState()
    resetMap()
    updateMap(viewModel.guessedCities)
    viewModel.saveGameState()
  }
  
  @objc private func didTapFinish() {
    let confirmFinishController = UIAlertController(title: "Finish and save?", message: "Are you sure you want to finish? You won't be able to add more cities, but your game will be saved permanently and you'll get a link to your results that you can share.", preferredStyle: .alert)
    
    confirmFinishController.addAction(.init(title: "Yes", style: .default, handler: { _ in
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.viewModel.finishGame()
      }
    }))
    confirmFinishController.addAction(.init(title: "Never mind", style: .cancel))
    
    present(confirmFinishController, animated: true)
  }
}

// TODO: Move this into separate file or vc???
extension MapGuessViewController {
  func showToast(_ message: String, toastType: ToastType) {
    let populationToast = MapToast(message, toastType: toastType).autolayoutEnabled
    populationToast.layer.opacity = 0
    populationToast.transform = .init(translationX: 0, y: 24)
    mapView.addSubview(populationToast)
    mapView.bringSubviewToFront(populationToast)
    NSLayoutConstraint.activate([
      populationToast.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
      populationToast.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -8),
      populationToast.widthAnchor.constraint(lessThanOrEqualTo: mapView.widthAnchor, multiplier: 0.66),
      ])
    
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
      populationToast.layer.opacity = 1
      populationToast.transform = .init(translationX: 0, y: 0)
    } completion: { _ in
      UIView.animate(withDuration: 0.2, delay: 1.8, options: .curveEaseOut) {
        populationToast.layer.opacity = 0
        populationToast.transform = .init(translationX: 0, y: -24)
      } completion: { _ in
        populationToast.removeFromSuperview()
      }
    }

  }
}

// MARK: - UITextFieldDelegate
extension MapGuessViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard textField == cityInputTextField else { return false }
    guard let textInput = textField.text,
          !textInput.isEmpty else {
            didReceiveError(.emptyGuess)
            return false
          }
    
    submitGuess(textInput)
    
    mapView.closeAllAnnotations()
    
    return false
  }
}

// MARK: - MapGuessDelegate
extension MapGuessViewController: MapGuessDelegate {
  func didChangeGuessMode(_ mode: GuessMode) {
    let ms = NSMutableAttributedString(attributedString: mode.shortDisplayName)
    ms.append(.init(string: " ▼"))
    countryDropdownButton.setAttributedTitle(ms, for: .normal)
  }
  
  func didReceiveCities(_ cities: [City]) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      self.cityInputTextField.text = ""
      self.updateMap(.init(cities))
      
      /*if cities.count > 1 {
        let center = cities.reduce(.init(latitude: 0, longitude: 0)) { acc, curr -> CLLocationCoordinate2D in
          return acc + curr.coordinates
        } / cities.count
        self.mapView.setCenter(center, animated: true)
      } else */if let lastCity = cities.last {
        self.mapView.setCenter(lastCity.coordinates, animated: true)
      }
      
      self.showToast("+\(cities.totalPopulation.abbreviated)", toastType: .population)
    }
  }
  
  func didReceiveError(_ error: CityGuessError) {
    // TODO: handle error
    DispatchQueue.main.async {
      self.cityInputTextField.shake()
      self.showToast(error.message, toastType: .error)
    }
  }
  
  func didSaveResult(_ response: GameFinishResponse?) {
    // TODO: better ui for sure here
    guard let response = response else {
      // TODO: ERROR HANDLING
      return
    }

    let resultLink = "https://iafisher.com/projects/cities/world/share/\(response.pk)"
    let alert = UIAlertController(title: "Congratulations! You named \(viewModel.numCitiesGuessed) world cities!", message: "Check out your results on the web at \(resultLink)", preferredStyle: .alert)
    alert.addAction(.init(title: "Open in web browser", style: .default, handler: { _ in
      DispatchQueue.main.async {
        guard let url = URL(string: resultLink) else { return } // TODO: error handling here!!!
        UIApplication.shared.open(url)
      }
    }))
    alert.addAction(.init(title: "Copy link", style: .default, handler: { _ in
      UIPasteboard.general.string = resultLink
    }))
    alert.addAction(.init(title: "Close", style: .cancel))
    
    DispatchQueue.main.async { [weak self] in
      self?.present(alert, animated: true) {
        self?.didConfirmReset()
      }
    }
    
    // TODO: Share sheet!
    // TODO: Tabulate saved results
  }

}

// MARK: - MKMapViewDelegate
extension MapGuessViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    viewModel.lastRegion = mapView.region
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let circle = overlay as? MKCircle {
      let circleRenderer = MKZoomableCircleRenderer(circle: circle)
      circleRenderer.fillColor = .systemRed.withAlphaComponent(0.5)
      circleRenderer.strokeColor = .systemFill
      circleRenderer.lineWidth = 2
      
      return circleRenderer
    } else if let polygon = overlay as? MKPolygon {
      let polygonRenderer = MKZoomablePolygonRenderer(polygon: polygon)
      polygonRenderer.fillColor = .systemYellow.withAlphaComponent(0.7)
      polygonRenderer.strokeColor = .systemFill
      polygonRenderer.lineWidth = 2
      
      return polygonRenderer
    } else if let tileOverlay = overlay as? MKTileOverlay {
//      return MKTileOverlayRenderer(tileOverlay: tileOverlay)
      return mapView.mapCacheRenderer(forOverlay: tileOverlay)
    }
    
    return .init(overlay: overlay)
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "MKAnnotationView", for: annotation)
    annotationView.canShowCallout = true
    return annotationView
  }
}

