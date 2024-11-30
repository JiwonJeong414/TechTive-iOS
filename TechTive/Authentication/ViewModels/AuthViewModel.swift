//
//  AuthViewModel.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    
    func login(username: String, password: String) {
        isAuthenticated = true
    }
    
    func signOut() {
        isAuthenticated = false
    }
}
