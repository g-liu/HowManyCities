//
//  ItemRenderer.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/6/22.
//

import Foundation
import UIKit

protocol ItemRenderer {
  associatedtype Item
  
  func render(_ item: Item) -> UIView?
  
  func string(_ item: Item) -> NSAttributedString
}
