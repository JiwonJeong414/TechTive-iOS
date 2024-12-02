//
//  TechTiveApp.swift
//  TechTive
//
//  Created by jiwon jeong on 11/24/24.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct TechTiveApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var notesViewModel = NotesViewModel()
    

  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
        ProfileView()
                .environmentObject(authViewModel)
                .environmentObject(notesViewModel)
      }
    }
  }
}
