//
//  MainView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//
import SwiftUI

// MARK: - Header Section View

private struct HeaderSection: View {
    let userName: String
    let profileImage: UIImage?
    let quote: String
    let showHeader: Bool
    let showQuote: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("HELLO " + self.userName.uppercased(with: .autoupdatingCurrent) + "!")
                    .font(.custom("Poppins-SemiBold", fixedSize: 32))
                    .foregroundColor(Color(Constants.Colors.darkPurple))
                Spacer()
                NavigationLink(destination: ProfileView()) {
                    if let profileImage = profileImage {
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
            .opacity(self.showHeader ? 1 : 0)

            Text(self.quote)
                .font(.custom("Poppins-Regular", fixedSize: 16))
                .foregroundColor(Color(Constants.Colors.orange))
                .opacity(self.showQuote ? 1 : 0)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Floating Action Button

private struct FloatingActionButton: View {
    let showAddButton: Bool
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color(Constants.Colors.orange))
                .clipShape(Circle())
                .shadow(
                    color: Color(Constants.Colors.orange).opacity(0.3),
                    radius: 4,
                    y: 2)
        }
        .scaleEffect(self.showAddButton ? 1 : 0, anchor: .center)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.75, blendDuration: 0.5).delay(1.2),
            value: self.showAddButton)
    }
}

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var profileImage: UIImage?

    @StateObject private var notesViewModel = NotesViewModel()
    @State private var showAddNote = false
    @StateObject private var viewModel = QuoteViewModel()

    // animation states
    @State private var showHeader = false
    @State private var showQuote = false
    @State private var showWeekly = false
    @State private var showNotes = false
    @State private var showAddButton = false

    private func loadProfilePicture() {
        Task {
            await self.authViewModel.fetchProfilePicture()
            if let urlString = authViewModel.profilePictureURL,
               let url = URL(string: urlString)
            {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.profileImage = image
                        }
                    }
                } catch {
                    print("Error loading profile picture: \(error)")
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    HeaderSection(
                        userName: self.authViewModel.currentUserName,
                        profileImage: self.profileImage,
                        quote: self.viewModel.quote,
                        showHeader: self.showHeader,
                        showQuote: self.showQuote)
                        .onAppear {
                            self.viewModel.fetchQuote()
                        }

                    WeeklyOverviewSection()
                        .opacity(self.showWeekly ? 1 : 0)
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("MY NOTES")
                            .font(.custom("Poppins-SemiBold", fixedSize: 32))
                            .foregroundColor(Color(Constants.Colors.darkPurple))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()

                        NotesFeedSection(viewModel: self.notesViewModel)
                    }
                    .opacity(self.showNotes ? 1 : 0)
                }
            }
            .background(Color(Constants.Colors.backgroundColor))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .overlay(
                GeometryReader { geometry in
                    FloatingActionButton(showAddButton: self.showAddButton) {
                        self.showAddNote = true
                    }
                    .offset(
                        x: geometry.size.width - 85,
                        y: geometry.size.height - 65)
                })
            .sheet(isPresented: self.$showAddNote) {
                AddNoteView(viewModel: self.notesViewModel)
                    .environmentObject(self.authViewModel)
            }
            .onAppear {
                self.loadProfilePicture()
                // Trigger animations with delays
                withAnimation(.easeIn(duration: 0.6)) {
                    self.showHeader = true
                }

                withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
                    self.showQuote = true
                }

                withAnimation(.easeIn(duration: 0.6).delay(0.6)) {
                    self.showWeekly = true
                }

                withAnimation(.easeIn(duration: 0.6).delay(0.9)) {
                    self.showNotes = true
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.2)) {
                    self.showAddButton = true
                }
            }
        }
        .onAppear {
            self.notesViewModel.authViewModel = self.authViewModel
            Task {
                await self.notesViewModel.fetchNotes()
            }
        }
    }
}
