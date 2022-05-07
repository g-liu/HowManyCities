//
//  StateInfoViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/6/22.
//

import UIKit

final class StateInfoViewController: UIViewController {
  
  var state: State? {
    didSet {
      // coming soon...
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    
  }
  
}
