//
//  MainViewModel.swift
//  TechTive
//

import SwiftUI

extension MainView {
    @MainActor class ViewModel: ObservableObject {
        
        // MARK: - Published Properties
        
        @Published var showHeader = false
        @Published var showQuote = false
        @Published var showWeekly = false
        @Published var showNotes = false
        @Published var showAddButton = false
        @Published var showAddNote = false
        @Published var refreshWeeklyAdvice = UUID()
        
        // MARK: - Properties
        
        private let animationDuration = 0.6
        private let springAnimation = Animation.spring(response: 0.6, dampingFraction: 0.7)
        
        // MARK: - Methods
        
        func startAnimations() {
            withAnimation(.easeIn(duration: animationDuration)) {
                showHeader = true
            }
            withAnimation(.easeIn(duration: animationDuration).delay(0.3)) {
                showQuote = true
            }
            withAnimation(.easeIn(duration: animationDuration).delay(0.6)) {
                showWeekly = true
            }
            withAnimation(.easeIn(duration: animationDuration).delay(0.9)) {
                showNotes = true
            }
            withAnimation(springAnimation.delay(1.2)) {
                showAddButton = true
            }
        }
        
        func toggleAddNote() {
            showAddNote.toggle()
        }
        
        func refreshWeeklyContent() {
            refreshWeeklyAdvice = UUID()
        }
    }
}
