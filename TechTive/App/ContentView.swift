//
//  ContentView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/24/24.
//

import SwiftUI


// MARK: - Main App Structure
struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isInitializing || authViewModel.isLoadingUserInfo {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .font(.custom("Poppins-Regular", fixedSize: 16))
                        .foregroundColor(.gray)
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
            } else if authViewModel.isAuthenticated {
                MainView()
            } else if authViewModel.isSecondState {
                LoginView()
            } else {
                AuthenticationFlow()
            }
        }
        .environmentObject(authViewModel)
    }
} 

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}




