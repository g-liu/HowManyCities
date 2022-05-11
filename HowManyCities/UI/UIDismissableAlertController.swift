//
//  UIDismissableAlertController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/11/22.
//

import Foundation
import UIKit


/// A subclass of `UIAlertController` that can be disabled by tapping outside of the alert
final class UIDismissableAlertController: UIAlertController {

  private func setupDismissGesture() {
    let tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(shouldDismiss))
    self.view.window?.isUserInteractionEnabled = true
    self.view.window?.addGestureRecognizer(tapToDismiss)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupDismissGesture()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    view.window?.removeAllGestureRecognizers()
  }
  
  @objc private func shouldDismiss(_ target: Any) {
    dismiss(animated: true)
  }
}
