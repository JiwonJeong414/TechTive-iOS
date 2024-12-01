//
//  TechTiveApp.swift
//  TechTive
//
//  Created by jiwon jeong on 11/24/24.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct TechTiveApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Configure Google Sign In
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "562148876818-46mhi6nlnofmme7qjm9li3bktle5vc7c.apps.googleusercontent.com")
        
        return true
    }
    
    func application(_ app: UIApplication,
                    open url: URL,
                    options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
