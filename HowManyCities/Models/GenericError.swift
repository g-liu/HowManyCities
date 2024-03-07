//
//  GenericError.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/9/22.
//

import Foundation

// WHY THE FUCK isn't there just a generic Error type already in Swift???
struct GenericError: Error { }
struct MaxRetriesExceededError: Error { }
