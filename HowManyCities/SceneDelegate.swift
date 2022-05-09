//
//  SceneDelegate.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
//    let token: Int = 572278
//    let path = URL(string: "https://iafisher.com/projects/cities/api/load?quiz=world&token=\(token)")!
////    let path = Bundle.main.url(forResource: "ukraine-montenegro-slovenia", withExtension: "json")!
//    let data = try! Data(contentsOf: path, options: .mappedIfSafe)
//    let cities = try! JSONDecoder().decode(Cities.self, from: data)
    
    
    
    
    // If you need massive amounts of test data...
    // How about EVERY SINGLE CITY???
    // https://docs.google.com/document/d/e/2PACX-1vQFFpGe37TNu7X4_Y8aPijZnTT00t449LjC1xndpP-o839B3hbnQgEKLtKzpCvjQ-TzqyrE3Nn6VuYK/pub
    
    
    let window = UIWindow(windowScene: windowScene)
//    let vc = MapGuessViewController(cities: cities)
    let vc = MapGuessViewController()
    window.rootViewController = vc
    window.makeKeyAndVisible()
    self.window = window
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }
  
  
}

