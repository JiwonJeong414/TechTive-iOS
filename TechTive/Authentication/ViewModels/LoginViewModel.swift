//
//  LoginViewModel.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var errorMessage: String? = nil
    @Published var isLoggedIn = false
    
    private let users: [String: String] = [
           "user1": "password1",
           "user2": "password2",
           "user3": "password3"
       ]

    
    func login() {
        errorMessage = nil
        
        guard !username.isEmpty, !password.isEmpty else {
                    errorMessage = "Username and Password cannot be empty."
                    return
                }
        if let storedPassword = users[username] {
                    if storedPassword == password {
                        isLoggedIn = true // Login success
                    } else {
                        errorMessage = "Password is incorrect."
                    }
                } else {
                    errorMessage = "Username does not exist."
                }
        
        // Implement login logic
    }
}
