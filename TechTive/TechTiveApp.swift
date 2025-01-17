//
//  TechTiveApp.swift
//  TechTive
//
//  Created by jiwon jeong on 11/24/24.
//

import SwiftUI
import FirebaseCore

@main
struct TechTiveApp: App {
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var notesViewModel: NotesViewModel
    
    init() {
        FirebaseApp.configure()
        let auth = AuthViewModel()
        _authViewModel = StateObject(wrappedValue: auth)
        _notesViewModel = StateObject(wrappedValue: NotesViewModel(authViewModel: auth))
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(authViewModel)
                    .environmentObject(notesViewModel)
            }
        }
    }
}
