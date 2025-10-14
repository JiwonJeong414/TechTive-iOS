//
//  MainView.swift
//  TechTive
//
//  Main View of TechTive
//

import SwiftUI

struct MainView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var notesViewModel = NotesViewModel()
    @StateObject private var quoteViewModel = QuoteViewModel()
    @StateObject private var viewModel = ViewModel()
    
    @State private var isRefreshing = false
    
    // MARK: - UI
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    headerSection
                    weeklyOverviewSection
                    notesSection
                }
            }
            .background(Color(Constants.Colors.backgroundColor))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .overlay(floatingActionButton)
            .refreshable {
                await refreshAllContent()
            }
            .sheet(isPresented: $viewModel.showAddNote) {
                AddNotesView()
                    .environmentObject(notesViewModel)
                    .environmentObject(authViewModel)
            }
            .onAppear {
                Task {
                    await authViewModel.loadProfilePicture()
                }
                viewModel.startAnimations()
            }
        }
        .task {
            // Set token once
            do {
                let token = try await authViewModel.getAuthToken()
                UserSessionManager.shared.accessToken = token
            } catch {
                print("Failed to get auth token: \(error)")
            }
            
            await notesViewModel.fetchNotes()
            await quoteViewModel.fetchQuoteFromAPI()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                Text("HELLO " + authViewModel.currentUserName.uppercased(with: .autoupdatingCurrent) + "!")
                    .font(Constants.Fonts.poppinsSemiBold32)
                    .foregroundColor(Color(Constants.Colors.darkPurple))
                Spacer()
                NavigationLink(destination: ProfileView(
                    authViewModel: authViewModel,
                    notesViewModel: notesViewModel
                )) {
                    if let profileImage = authViewModel.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle")
                            .font(.title2)
                            .foregroundColor(Color(Constants.Colors.darkPurple))
                    }
                }
            }
            .opacity(viewModel.showHeader ? 1 : 0)
            
            if !quoteViewModel.quote.isEmpty {
                Text(quoteViewModel.quote)
                    .font(Constants.Fonts.poppinsRegular16)
                    .foregroundColor(Color(Constants.Colors.orange))
                    .opacity(viewModel.showQuote ? 1 : 0)
                    .padding(.top, 2)
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var weeklyOverviewSection: some View {
        WeeklyOverviewSection()
            .opacity(viewModel.showWeekly ? 1 : 0)
            .padding(.horizontal)
            .id(viewModel.refreshWeeklyAdvice)
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("MY NOTES")
                .font(Constants.Fonts.poppinsSemiBold32)
                .foregroundColor(Color(Constants.Colors.darkPurple))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            NotesFeedSection()
                .environmentObject(notesViewModel)
        }
        .opacity(viewModel.showNotes ? 1 : 0)
    }
    
    private var floatingActionButton: some View {
        GeometryReader { geometry in
            Button(action: { viewModel.toggleAddNote() }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(Constants.Colors.white))
                    .frame(width: 56, height: 56)
                    .background(Color(Constants.Colors.orange))
                    .clipShape(Circle())
                    .shadow(
                        color: Color(Constants.Colors.orange).opacity(0.3),
                        radius: 4,
                        y: 2
                    )
            }
            .scaleEffect(viewModel.showAddButton ? 1 : 0, anchor: .center)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.75, blendDuration: 0.5).delay(1.2),
                value: viewModel.showAddButton
            )
            .offset(
                x: geometry.size.width - 85,
                y: geometry.size.height - 65
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func refreshAllContent() async {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        defer { isRefreshing = false }
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        do {
            await quoteViewModel.fetchQuoteFromAPI()
        } catch {
            if !error.localizedDescription.contains("cancelled") {
                print("Error refreshing quote: \(error)")
            }
        }
        
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        do {
            await notesViewModel.fetchNotes()
        } catch {
            if !error.localizedDescription.contains("cancelled") {
                print("Error refreshing notes: \(error)")
            }
        }
        
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        viewModel.refreshWeeklyContent()
    }
}
