//
//  ProfileView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI
import Charts

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    
    @Environment(\.dismiss) var dismiss
    private let buttonColor = Color(UIColor.color.lightYellow)
    private let purpleColor = Color(UIColor.color.purple)
    
    var body: some View {
        ScrollView {
             VStack(spacing: 0) {
                 // Profile Header Section with Purple Background
                 ZStack {
                     GeometryReader { geometry in
                         purpleColor
                             .frame(width: geometry.size.width, height: geometry.size.height + geometry.frame(in: .global).minY)
                             .offset(y: -geometry.frame(in: .global).minY)
                             .allowsHitTesting(false)
                     }
                     
                     VStack {
                         // Back button aligned to the left
                         HStack {
                             Button(action: {
                                 print("Dismiss tapped")
                                 dismiss()
                             }) {
                                 HStack {
                                     Image(systemName: "chevron.left")
                                         .foregroundColor(.orange)
                                     Text("Back")
                                         .font(.custom("Poppins-Medium", size: 16))
                                         .foregroundColor(.orange)
                                 }.padding(.top, 70)
                             }
                             Spacer()
                         }
                         .padding(.top, 30)
                         .padding(.horizontal)
                         
                         Image(systemName: "person.circle.fill")
                             .resizable()
                             .frame(width: 160, height: 160)
                             .foregroundColor(.gray)
                         
                         Text(authViewModel.currentUserName)
                             .font(.custom("Poppins-Medium", size: 24))
                             .foregroundColor(Color(UIColor.color.darkPurple))
                         
                         Text(authViewModel.currentUserEmail)
                             .font(.custom("Poppins-Medium", size: 16))
                             .foregroundColor(Color(UIColor.color.darkPurple))
                             .padding(.bottom, 32)
                     }
                     .padding(.horizontal)
                 }
                 .frame(height: 300)
                 
                 // Yellow Background Section
                 ZStack {
                     GeometryReader { geometry in
                         Color(UIColor.color.lightYellow).opacity(0.3)
                             .frame(width: geometry.size.width, height: geometry.size.height + geometry.frame(in: .global).minY)
                             .offset(y: -geometry.frame(in: .global).minY)
                             .allowsHitTesting(false)
                     }
                     
                     VStack(spacing: 0) {
                         // Profile Settings/Options
                         VStack(spacing: 0) {
                             HStack {
                                 NavigationLink(destination: ProfileEditView().environmentObject(authViewModel).environmentObject(notesViewModel)){
                                     Text("Edit Profile")
                                         .foregroundColor(.black)
                                         .font(.custom("CourierPrime-Regular", size: 16))
                                     Spacer()
                                     Image(systemName: "chevron.right")
                                         .foregroundColor(.orange)
                                 }
                             }
                             .padding()
                             .frame(maxWidth: .infinity)
                             .background(buttonColor)
                             
                             Divider()
                                 .background(Color.orange)
                             
                             // Settings Button
                             Button(action: {
                                 // Add settings action
                             }) {
                                 HStack {
                                     Text("Settings")
                                         .foregroundColor(.black)
                                         .font(.custom("CourierPrime-Regular", size: 16))
                                     Spacer()
                                     Image(systemName: "chevron.right")
                                         .foregroundColor(.orange)
                                 }
                                 .padding()
                                 .frame(maxWidth: .infinity)
                                 .background(buttonColor)
                             }
                             
                             Divider()
                                 .background(Color.orange)
                             
                             // Logout Button
                             Button(action: {
                                 authViewModel.signOut()
                             }) {
                                 HStack {
                                     Text("Logout")
                                         .foregroundColor(.red)
                                         .font(.custom("CourierPrime-Regular", size: 16))
                                     Spacer()
                                     Image(systemName: "chevron.right")
                                         .foregroundColor(.orange)
                                 }
                                 .padding()
                                 .frame(maxWidth: .infinity)
                                 .background(buttonColor)
                             }
                         }
                         .padding(.horizontal)
                         .background(buttonColor)
                         .cornerRadius(8)
                         .frame(width: 380)
                         .padding(.top, 60)
                         .padding(.bottom, 15)
                         
                         // Stats Section
                         VStack(alignment: .leading, spacing: 16) {
                             // Your existing stats section code remains the same
                             Divider()
                             
                             Text("MY STATS")
                                 .font(.custom("Poppins-SemiBold", size: 20))
                                 .padding(.leading)
                             
                             // Graph Section
                             VStack(spacing: 8) {
                                 Text("Notes Last 5 Weeks")
                                     .font(.custom("Poppins-Medium", size: 16))
                                     .foregroundColor(.black)
                                 
                                 Chart {
                                     ForEach(notesViewModel.notesPerWeek(), id: \.week) { data in
                                         BarMark(
                                             x: .value("Week", data.week),
                                             y: .value("Count", data.count)
                                         )
                                         .foregroundStyle(Color.orange)
                                     }
                                 }
                                 .frame(height: 200)
                                 .padding(.horizontal, 4)
                             }
                             .frame(height: 240)
                             .background(Color.yellow.opacity(0.4))
                             .cornerRadius(12)
                             .padding(.horizontal)
                             
                             // Stats Cards
                             HStack(spacing: 16) {
                                 StatCard(
                                     title: "Total Notes",
                                     value: "\(notesViewModel.notes.count)"
                                 )
                                 
                                 StatCard(
                                     title: "Average Notes/Week",
                                     value: String(format: "%.1f", notesViewModel.notes.isEmpty ? 0 : Double(notesViewModel.notes.count) / 7.0)
                                 )
                                 
                                 StatCard(
                                     title: "Longest Streak",
                                     value: "3 Weeks"
                                 )
                             }
                             .padding(.horizontal)
                         }
                     }
                 }
             }
         }
         .navigationBarBackButtonHidden(true)
         .ignoresSafeArea(.all, edges: .top)
        }
    
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .lineLimit(2)
            
            Text(value)
                .font(.custom("Poppins-SemiBold", size: 20))
                .foregroundColor(.orange)
        }
        .frame(width: 110, height: 110)
        .background(Color.yellow.opacity(0.4))
        .cornerRadius(12)
    }
}
#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(NotesViewModel())
}
