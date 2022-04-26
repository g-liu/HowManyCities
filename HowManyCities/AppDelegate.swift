//
//  AppDelegate.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import UIKit

struct Global {
  static let COUNTRY_NAMES_TO_LOCALES: [String: String] = {
    let identifier = NSLocale(localeIdentifier: "en_US")
    return Dictionary(uniqueKeysWithValues:
                        NSLocale.isoCountryCodes.compactMap { localeCode in
      guard let countryName = identifier.displayName(forKey: NSLocale.Key.countryCode, value: localeCode) else {
        return nil
      }
      
      return (countryName, localeCode)
    })
  }()
  
  static let STATE_ABBREVIATIONS: [String: String] = {
    guard let url = Bundle.main.url(forResource: "StateAbbreviations", withExtension: "plist") else { return [:] }
    
    do {
      let data = try Data(contentsOf: url)
      let decoder = PropertyListDecoder()
      return try decoder.decode([String: String].self, from: data)
    } catch {
      print("Unable to read plist of state abbreviations")
      return [:]
    }
  }()
  
  static let NORMALIZED_COUNTRY_NAMES: [String: String] = {
    guard let url = Bundle.main.url(forResource: "NormalizedCountryNames", withExtension: "plist") else { return [:] }
    
    do {
      let data = try Data(contentsOf: url)
      let decoder = PropertyListDecoder()
      return try decoder.decode([String: String].self, from: data)
    } catch {
      print("Unable to read plist of normalized country names")
      return [:]
    }
  }()
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    let _ = HMCRequestHandler.shared
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }

}

