//
//  AuthViewModel.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLimitedAccess = false
    
    func enableLimitedAccess() {
        isLimitedAccess = true
        print("Limited access enabled")
    }
    
    func login(username: String, password: String) {
        isAuthenticated = true
        isLimitedAccess = false
    }
    
    func signOut() {
        isAuthenticated = false
        isLimitedAccess = false
    }
}
