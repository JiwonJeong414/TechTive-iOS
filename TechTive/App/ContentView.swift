//
//  ContentView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/24/24.
//

import SwiftUI


// MARK: - Main App Structure
struct ContentView: View { 
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainView()
            } else if authViewModel.isSecondState{
                LoginView()
            }
            else {
                AuthenticationFlow()
            }
        }
        .environmentObject(authViewModel)
    }
} 
   
#Preview { 
    ContentView()
}
 
 
 

