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
  
  private static let searchURL = "https://cityquiz.io/api/cities/search"
  private static let configWorldURL = "https://cityquiz.io/api/config/get?quiz=world"
  private static let finishGameURL = "https://cityquiz.io/api/sessions/save-anonymous"
  private static let gameURL = "https://cityquiz.io/quizzes/world"
  
  private init() {
    retrieveCSRFToken()
  }
  
  private func retrieveCSRFToken(_ retries: Int = 3, cb: (() -> Void)? = nil) {
    guard retries > 0 else {
      print("Sorry, cannot retry")
      return
    }
    
    // get csrf token
    guard let url = URL(string: type(of: self).gameURL) else { return }
    
    var request = URLRequest(url: url, timeoutInterval: Double.infinity)
    request.httpMethod = "GET" // Sadly HEAD is not longer allowed
    
    let task = URLSession.hmcShared.dataTask(with: request) { [weak self] data, response, error in
      // check for errors
      if let error = error {
        if (error as NSError).code == NSURLErrorTimedOut {
          // TODO: Alert timeout and retry
          print("Timeout. Will retry \(retries) more time(s)")
          self?.retrieveCSRFToken(retries-1)
          return
        }
      }
      
      guard let httpResponse = (response as? HTTPURLResponse) else { return }
      
      // NOW API is failing here
      guard let cookieField = httpResponse.allHeaderFields["Set-Cookie"] as? String else { return }
      
      guard let csrfTokenCookie = cookieField.split(separator: ";").first(where: { $0.starts(with: "csrftoken") }) else { return }
      
      guard let csrfTokenValue = csrfTokenCookie.split(separator: "=", maxSplits: 2, omittingEmptySubsequences: true).last else { return }
      
      self?.csrfToken = String(csrfTokenValue)
    }
    
    task.resume()
  }
  
  func retrieveConfiguration(_ retries: Int = 3, cb: @escaping (GameConfiguration?) -> Void) {
    guard retries > 0 else {
      print("Too many retries.")
      return
    }
    
    guard let url = URL(string: type(of: self).configWorldURL) else { cb(nil); return }
    
    var request = URLRequest(url: url, timeoutInterval: Double.infinity)
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    request.httpMethod = "GET"

    let task = URLSession.hmcShared.dataTask(with: request) { [weak self] data, response, error in
      if let error = error {
        if (error as NSError).code == NSURLErrorTimedOut {
          // TODO: Alert timeout and retry
          print("Timeout. Will retry \(retries) more time(s)")
          self?.retrieveConfiguration(retries-1, cb: cb)
          return
        }
      }
      guard let data = data else {
        cb(nil)
        return
      }
      
      let decoder = JSONDecoder()
      do {
        let result = try decoder.decode(GameConfiguration.self, from: data)
        cb(result)
      } catch {
          print("error: \(error)")
      }
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

    guard var components = URLComponents(string: type(of: self).searchURL) else { cb(nil); return }
    
    let dropdownValue = state.isEmpty ? country : "\(state), \(country)"
    
    components.queryItems = .init()
    components.queryItems?.append(.init(name: "query", value: city))
    components.queryItems?.append(.init(name: "dropdown", value: dropdownValue))
    components.queryItems?.append(.init(name: "quiz", value: "world")) // TODO: Different game modes
    
    guard let url = components.url else { cb(nil); return }
    
    
    var request = URLRequest(url: url, timeoutInterval: 5) // TODO: Revisit timeout val
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    request.httpMethod = "GET"

    let task = URLSession.hmcShared.dataTask(with: request) { data, response, error in
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
  
  func finishGame(_ retries: Int = 3, cities: [City], startTime: Date, usedMultiCityInput: Bool, cb: @escaping (GameFinishResponse?) -> Void) {
    guard retries > 0 else {
      print("Too many retries.")
      return
    }
    guard let url = URL(string: type(of: self).finishGameURL) else { cb(nil); return }
    guard let csrfToken = csrfToken else {
      retrieveCSRFToken(1) { [weak self] in
        self?.finishGame(cities: cities, startTime: startTime, usedMultiCityInput: usedMultiCityInput, cb: cb)
      }
      return
    }

    
    var request = URLRequest(url: url, timeoutInterval: 5)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(csrfToken, forHTTPHeaderField: "X-CSRFToken")
    request.addValue(type(of: self).gameURL, forHTTPHeaderField: "Referer")
    
    request.httpMethod = "POST"
    
    let requestBody = GameFinishRequestBody(cities: cities.map(by: \.asShortForm), quiz: "world", startTime: Int(startTime.timeIntervalSince1970), usedMultiCityInput: usedMultiCityInput)
    let encoder = JSONEncoder()
    do {
      request.httpBody = try encoder.encode(requestBody)
    } catch {
      print("can't encode finish request body: \(error)")
    }

    let task = URLSession.hmcShared.dataTask(with: request) { [weak self] data, response, error in
      if let error = error {
        if (error as NSError).code == NSURLErrorTimedOut {
          // TODO: Alert timeout and retry
          print("Timeout. Will retry \(retries) more time(s)")
          self?.finishGame(retries-1, cities: cities, startTime: startTime, usedMultiCityInput: usedMultiCityInput, cb: cb)
          return
        }
      }
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


private extension URLSession {
  static let hmcShared: URLSession = {
    let configuration = URLSessionConfiguration.default

    configuration.timeoutIntervalForRequest = 30
    configuration.timeoutIntervalForResource = 60
    return .init(configuration: configuration)
  }()
}
