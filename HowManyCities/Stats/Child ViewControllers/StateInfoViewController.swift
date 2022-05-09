//
//  StateInfoViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/6/22.
//

import UIKit

final class StateInfoViewController: UIViewController {
  
  let state: State
  let guessedCities: [City]
  
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
    
  }
  
}
