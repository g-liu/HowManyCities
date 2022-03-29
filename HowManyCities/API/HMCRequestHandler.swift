//
//  HMCRequestHandler.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import Foundation

// TODO: Protocolize this for testing
final class HMCRequestHandler {
  static let baseURL = "https://iafisher.com/projects/cities/api/search/v2"
  static let configURL = "https://iafisher.com/projects/cities/api/config/world"
  
  static func retrieveConfiguration(cb: @escaping (GameConfiguration?) -> Void) {
    guard let url = URL(string: configURL) else { cb(nil); return }
    
    var request = URLRequest(url: url, timeoutInterval: Double.infinity)
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    request.httpMethod = "GET"

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data else {
        cb(nil)
        return
      }
      
      let decoder = JSONDecoder()
      let result = try? decoder.decode(GameConfiguration.self, from: data)
      cb(result)
    }

    task.resume()
  }
  
  static func submitRequest(string: String, cb: @escaping (Cities?) -> Void) {
    let locationFragments = string.split(maxSplits: 3, omittingEmptySubsequences: true) { $0 == "," }
    guard locationFragments.count >= 1 else { cb(nil); return }
    
    let city, state, country: String
    
    // TODO: This will have to change based on the game mode
    if locationFragments.count == 1 {
      city = locationFragments.first?.trimmingCharacters(in: .whitespaces) ?? ""
      state = ""
      country = ""
    } else if locationFragments.count == 2 {
      city = locationFragments.first?.trimmingCharacters(in: .whitespaces) ?? ""
      country = locationFragments[1].trimmingCharacters(in: .whitespaces)
      state = ""
    } else if locationFragments.count >= 3 {
      city = locationFragments.first?.trimmingCharacters(in: .whitespaces) ?? ""
      state = locationFragments[1].trimmingCharacters(in: .whitespaces)
      country = locationFragments[2].trimmingCharacters(in: .whitespaces)
    } else {
      cb(nil)
      return // FATAL ERROR
    }

    guard var components = URLComponents(string: baseURL) else { cb(nil); return }
    
    components.queryItems = .init()
    components.queryItems?.append(.init(name: "city", value: city))
    components.queryItems?.append(.init(name: "state", value: state))
    components.queryItems?.append(.init(name: "country", value: country))
    components.queryItems?.append(.init(name: "quiz", value: "world")) // TODO: Different game modes
    
    guard let url = components.url else { cb(nil); return }
    
    
    var request = URLRequest(url: url, timeoutInterval: Double.infinity) // TODO: Revisit timeout val
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    request.httpMethod = "GET"

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data else { cb(nil); return }

      let decoder = JSONDecoder()
      
      let result = try? decoder.decode(Cities.self, from: data)
      cb(result)
    }

    task.resume()
  }
}
