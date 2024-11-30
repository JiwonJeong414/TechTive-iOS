//
//  MainView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//
import SwiftUI

struct MainView: View {
    @StateObject private var notesViewModel = NotesViewModel()
    @State private var showAddNote = false
    let isLimitedAccess: Bool
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("HELLO, PERSON!")
                            .font(.custom("Poppins-SemiBold", size: 24))
                            .foregroundColor(Color(UIColor.color.darkPurple))
                        Text("Lorem ipsum dolor sit am")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(Color(UIColor.color.orange))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    
                    // Weekly Overview Section
                    WeeklyOverviewSection(isLimitedAccess: isLimitedAccess)
                        .background(Color(UIColor.color.lightYellow))
                        .cornerRadius(12)
                    
                    // Notes Section Title
                    Text("MY NOTES")
                        .font(.custom("Poppins-SemiBold", size: 24))
                        .foregroundColor(Color(UIColor.color.darkPurple))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Notes Feed
                    NotesFeedSection(viewModel: notesViewModel, isLimitedAccess: isLimitedAccess)
                }
                .padding()
            }
            .background(Color(UIColor.color.backgroundColor))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !isLimitedAccess {
                        NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.circle")
                                .font(.title2)
                                .foregroundColor(Color(UIColor.color.darkPurple))
                        }
                    } else {
                        NavigationLink(destination: AuthenticationFlow()) {
                            Text("Login")
                                .font(.custom("Poppins-Medium", size: 16))
                                .foregroundColor(Color(UIColor.color.orange))
                        }
                    }
                }
            }
            .overlay(
                Group {
                    if !isLimitedAccess {
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
                        .padding()
                        .offset(x: UIScreen.main.bounds.width/2 - 60,
                               y: UIScreen.main.bounds.height/2 - 120)
                    }
                }
            )
            .sheet(isPresented: $showAddNote) {
                AddNoteView(viewModel: notesViewModel, userId: "123")
            }
        }
    }
}



#Preview {
    MainView(isLimitedAccess: false)
}
