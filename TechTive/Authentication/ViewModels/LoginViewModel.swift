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
    
    func login() {
        // Implement login logic
    }
}
