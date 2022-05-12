//
//  CityLimitWarning.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/11/22.
//

import Foundation

enum CityLimitWarning: Equatable {
  case none
  case warning(_ remaining: Int)
  case unableToSave(_ surplus: Int)
}
