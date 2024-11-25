//
//  SignUpViewModel.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    func signUp() {
        // Implement sign up logic
    }
}
