//
//  MainView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//
import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var profileImage: UIImage?
    
    @StateObject private var notesViewModel = NotesViewModel()
    @State private var showAddNote = false
    @StateObject private var viewModel = QuoteViewModel()
    //animation states
    @State private var showHeader = false
    @State private var showQuote = false
    @State private var showWeekly = false
    @State private var showNotes = false
    @State private var showAddButton = false
    
    private func loadProfilePicture() {
        Task {
            await authViewModel.fetchProfilePicture()
            if let urlString = authViewModel.profilePictureURL,
               let url = URL(string: urlString) {
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
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack{
                            Text("HELLO " + authViewModel.currentUserName.uppercased(with: .autoupdatingCurrent) + "!")
                                .font(.custom("Poppins-SemiBold", size: 32))
                                .foregroundColor(Color(UIColor.color.darkPurple))
                            Spacer()
                            NavigationLink(destination: ProfileView().environmentObject(notesViewModel).environmentObject(authViewModel)) {
                                if let profileImage = profileImage {
                                    Image(uiImage: profileImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 44, height: 44)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle")
                                        .font(.title2)
                                        .foregroundColor(Color(UIColor.color.darkPurple))
                                }
                            }
                        }
                        .opacity(showHeader ? 1 : 0)
                        
                        Text(viewModel.quote)
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(Color(UIColor.color.orange))
                            .opacity(showQuote ? 1 : 0)
                            .onAppear {
                                viewModel.fetchQuote()
                            }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Weekly Overview Section
                    WeeklyOverviewSection()
                        .opacity(showWeekly ? 1 : 0)
                        .padding(.horizontal)
                    
                    // Notes Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MY NOTES")
                            .font(.custom("Poppins-SemiBold", size: 32))
                            .foregroundColor(Color(UIColor.color.darkPurple))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        
                        NotesFeedSection(viewModel: notesViewModel)
                    }
                    .opacity(showNotes ? 1 : 0)
                }
            }
            .background(Color(UIColor.color.backgroundColor))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .overlay(
                GeometryReader { geometry in
                    Group {
                        Button(action: {
                            showAddNote = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color(UIColor.color.orange))
                                .clipShape(Circle())
                                .shadow(color: Color(UIColor.color.orange).opacity(0.3),
                                        radius: 4, y: 2)
                        }
                        .offset(
                            x: geometry.size.width - 85,
                            y: geometry.size.height - 65
                        )
                        .scaleEffect(showAddButton ? 1 : 0, anchor: .center)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.75, blendDuration: 0.5).delay(1.2),
                            value: showAddButton
                        )
                    }
                }
            )
            .sheet(isPresented: $showAddNote) {
                AddNoteView(viewModel: notesViewModel)
                    .environmentObject(authViewModel)
            }
            .onAppear {
                loadProfilePicture()
                // Trigger animations with delays
                withAnimation(.easeIn(duration: 0.6)) {
                    showHeader = true
                }
                
                withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
                    showQuote = true
                }
                
                withAnimation(.easeIn(duration: 0.6).delay(0.6)) {
                    showWeekly = true
                }
                
                withAnimation(.easeIn(duration: 0.6).delay(0.9)) {
                    showNotes = true
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.2)) {
                    showAddButton = true
                }
            }
        }
        .onAppear {
            notesViewModel.authViewModel = authViewModel
            Task {
                await notesViewModel.fetchNotes()
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
}
