//
//  HMCRequestHandler.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import Foundation

// TODO: Protocolize this for testing
final class HMCRequestHandler {
  static let shared = HMCRequestHandler()
  
  private var csrfToken: String?
  
  private static let baseURL = "https://iafisher.com/projects/cities/api/search/v2"
  private static let configWorldURL = "https://iafisher.com/projects/cities/api/config/world"
  private static let finishGameURL = "https://iafisher.com/projects/cities/api/finish"
  
  private init() {
    retrieveCSRFToken()
  }
  
  private func retrieveCSRFToken() {
    // get csrf token
    guard let url = URL(string: "https://iafisher.com/projects/cities/world") else { return }
    
    var request = URLRequest(url: url, timeoutInterval: Double.infinity)
    request.httpMethod = "HEAD"
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      guard let httpResponse = (response as? HTTPURLResponse) else { return }
      
      guard let cookieField = httpResponse.allHeaderFields["Set-Cookie"] as? String else { return }
      
      guard let csrfTokenCookie = cookieField.split(separator: ";").first(where: { $0.starts(with: "csrftoken") }) else { return }
      
      guard let csrfTokenValue = csrfTokenCookie.split(separator: "=", maxSplits: 2, omittingEmptySubsequences: true).last else { return }
      
      self.csrfToken = String(csrfTokenValue)
    }
    
    task.resume()
  }
  
  func retrieveConfiguration(cb: @escaping (GameConfiguration?) -> Void) {
    guard let url = URL(string: type(of: self).configWorldURL) else { cb(nil); return }
    
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
  
  func submitGuess(_ guess: String, cb: @escaping (Cities?) -> Void) {
    let locationFragments = guess.split(maxSplits: 3, omittingEmptySubsequences: true) { $0 == "," }
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

    guard var components = URLComponents(string: type(of: self).baseURL) else { cb(nil); return }
    
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
      
      do {
        let result = try decoder.decode(Cities.self, from: data)
        cb(result)
      } catch {
        print("error: \(error)")
      }
    }

    task.resume()
  }
  
  func finishGame(cities: [City], startTime: Date, usedMultiCityInput: Bool, cb: @escaping (GameFinishResponse?) -> Void) {
    guard let url = URL(string: type(of: self).finishGameURL) else { cb(nil); return }
    guard let csrfToken = csrfToken else {
      // TODO: Let the user know...
      cb(nil)
      return
    }

    
    var request = URLRequest(url: url, timeoutInterval: 5)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(csrfToken, forHTTPHeaderField: "X-CSRFToken")
    
    request.httpMethod = "POST"
    
    let requestBody = GameFinishRequestBody(cities: cities.map(by: \.asShortForm), quiz: "world", startTime: Int(startTime.timeIntervalSince1970), usedMultiCityInput: usedMultiCityInput)
    let encoder = JSONEncoder()
    do {
      request.httpBody = try encoder.encode(requestBody)
    } catch {
      print("can't encode finish request body: \(error)")
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data else {
        print(String(describing: error))
        return
      }
      
      print(String(data: data, encoding: .utf8)!)
      let decoder = JSONDecoder()
      let result = try? decoder.decode(GameFinishResponse.self, from: data)
      cb(result)
    }

    task.resume()
  }
}
