//
//  MainView.swift
//  TechTive
//

import SwiftUI

/// Main View of TechTive
struct MainView: View {
    // MARK: - Properties

    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var notesViewModel: NotesViewModel
    @StateObject private var quoteViewModel = QuoteViewModel()
    @StateObject private var viewModel = ViewModel()

    @State private var profileImage: UIImage?
    @State private var isRefreshing = false
    @State private var refreshWeeklyAdvice = UUID()

    // MARK: - Initialization

    init() {
        // Simple initialization - no authViewModel needed
        _notesViewModel = StateObject(wrappedValue: NotesViewModel())
    }

    // MARK: - UI

    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 20) {
                        self.headerSection
                        self.weeklyOverviewSection
                        self.notesSection
                    }
                }
                .background(Color(Constants.Colors.backgroundColor))
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .overlay(self.floatingActionButton)
                .refreshable {
                    await self.refreshAllContent()
                }
                .sheet(isPresented: self.$viewModel.showAddNote) {
                    AddNotesView()
                        .environmentObject(self.notesViewModel)
                        .environmentObject(self.authViewModel)
                }
                .onAppear {
                    Task { await self.authViewModel.loadProfilePicture() }
                    self.viewModel.startAnimations()
                }
            }
        }
        .onAppear {
            // Set token in UserSessionManager once
            Task {
                do {
                    let token = try await self.authViewModel.getAuthToken()
                    UserSessionManager.shared.accessToken = token
                } catch {
                    print("Failed to get auth token: \(error)")
                }
            }
            
            // Simplified - no need to pass authViewModel around
            Task {
                await self.notesViewModel.fetchNotes()
            }
            Task {
                await self.quoteViewModel.fetchQuoteFromAPI()
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                Text("HELLO " + self.authViewModel.currentUserName.uppercased(with: .autoupdatingCurrent) + "!")
                    .font(Constants.Fonts.poppinsSemiBold32)
                    .foregroundColor(Color(Constants.Colors.darkPurple))
                Spacer()
                NavigationLink(destination: ProfileView(
                    authViewModel: self.authViewModel,
                    notesViewModel: self.notesViewModel))
                {
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
            .opacity(self.viewModel.showHeader ? 1 : 0)

            if !self.quoteViewModel.quote.isEmpty {
                Text(self.quoteViewModel.quote)
                    .font(Constants.Fonts.poppinsRegular16)
                    .foregroundColor(Color(Constants.Colors.orange))
                    .opacity(self.viewModel.showQuote ? 1 : 0)
                    .padding(.top, 2)
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var weeklyOverviewSection: some View {
        WeeklyOverviewSection()
            .opacity(self.viewModel.showWeekly ? 1 : 0)
            .padding(.horizontal)
            .id(self.refreshWeeklyAdvice)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("MY NOTES")
                .font(Constants.Fonts.poppinsSemiBold32)
                .foregroundColor(Color(Constants.Colors.darkPurple))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            NotesFeedSection()
                .environmentObject(self.notesViewModel)
        }
        .opacity(self.viewModel.showNotes ? 1 : 0)
    }

    private var floatingActionButton: some View {
        GeometryReader { geometry in
            Button(action: { self.viewModel.toggleAddNote() }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(Constants.Colors.white))
                    .frame(width: 56, height: 56)
                    .background(Color(Constants.Colors.orange))
                    .clipShape(Circle())
                    .shadow(
                        color: Color(Constants.Colors.orange).opacity(0.3),
                        radius: 4,
                        y: 2)
            }
            .scaleEffect(self.viewModel.showAddButton ? 1 : 0, anchor: .center)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.75, blendDuration: 0.5).delay(1.2),
                value: self.viewModel.showAddButton)
            .offset(
                x: geometry.size.width - 85,
                y: geometry.size.height - 65)
        }
    }

    // MARK: - Private Methods

    private func refreshAllContent() async {
        // Prevent multiple simultaneous refresh requests
        guard !self.isRefreshing else { return }

        self.isRefreshing = true
        defer { isRefreshing = false }

        // Add longer delay to let any existing requests finish
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay

        // Run requests with error handling to ignore cancellation errors
        do {
            await self.quoteViewModel.fetchQuoteFromAPI()
        } catch {
            if !error.localizedDescription.contains("cancelled") {
                print("Error refreshing quote: \(error)")
            }
        }

        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 second delay

        do {
            await self.notesViewModel.fetchNotes()
        } catch {
            if !error.localizedDescription.contains("cancelled") {
                print("Error refreshing notes: \(error)")
            }
        }

        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 second delay

        // Trigger weekly advice refresh last
        self.refreshWeeklyAdvice = UUID()
    }
}
