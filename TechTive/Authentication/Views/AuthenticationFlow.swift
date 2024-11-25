//
//  AuthenticationFlow.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

struct AuthenticationFlow: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSignUp = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Skip") {
                    authViewModel.enableLimitedAccess()
                }
                .padding()
            }
            
            LoginView()
            
            Button("Don't have an account? Sign up") {
                showSignUp = true
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}
