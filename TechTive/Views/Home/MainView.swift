import SwiftUI

/// Main View of TechTive
struct MainView: View {
    // MARK: - Properties

    @EnvironmentObject var authViewModel: AuthViewModel

    @StateObject private var notesViewModel = NotesViewModel()
    @StateObject private var viewModel = QuoteViewModel()

    @State private var profileImage: UIImage?

    @State private var showAddNote = false
    @State private var showHeader = false
    @State private var showQuote = false
    @State private var showWeekly = false
    @State private var showNotes = false
    @State private var showAddButton = false

    // MARK: - UI

    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 20) {
                        self.headerSection

                        Spacer(minLength: 8)

                        self.weeklyOverviewSection

                        Spacer(minLength: 8)

                        self.notesSection
                    }
                }
                .background(Color(Constants.Colors.backgroundColor))
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .overlay(self.floatingActionButton)
                .sheet(isPresented: self.$showAddNote) {
                    AddNotesView()
                        .environmentObject(self.notesViewModel)
                        .environmentObject(self.authViewModel)
                }
                .onAppear {
                    Task { await self.authViewModel.loadProfilePicture() }
                    withAnimation(.easeIn(duration: 0.6)) { self.showHeader = true }
                    withAnimation(.easeIn(duration: 0.6).delay(0.3)) { self.showQuote = true }
                    withAnimation(.easeIn(duration: 0.6).delay(0.6)) { self.showWeekly = true }
                    withAnimation(.easeIn(duration: 0.6).delay(0.9)) { self.showNotes = true }
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.2)) { self.showAddButton = true }
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

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                Text("HELLO " + self.authViewModel.currentUserName.uppercased(with: .autoupdatingCurrent) + "!")
                    .font(.custom("Poppins-SemiBold", fixedSize: 32))
                    .foregroundColor(Color(Constants.Colors.darkPurple))
                Spacer()
                NavigationLink(destination: ProfileView()
                    .environmentObject(self.authViewModel)
                    .environmentObject(self.notesViewModel))
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
            .opacity(self.showHeader ? 1 : 0)

            Text(self.viewModel.quote)
                .font(.custom("Poppins-Regular", fixedSize: 16))
                .foregroundColor(Color(Constants.Colors.orange))
                .opacity(self.showQuote ? 1 : 0)
                .padding(.top, 2)
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            self.viewModel.fetchQuote()
        }
    }

    private var weeklyOverviewSection: some View {
        WeeklyOverviewSection()
            .opacity(self.showWeekly ? 1 : 0)
            .padding(.horizontal)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("MY NOTES")
                .font(.custom("Poppins-SemiBold", fixedSize: 32))
                .foregroundColor(Color(Constants.Colors.darkPurple))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            NotesFeedSection()
                .environmentObject(self.notesViewModel)
        }
        .opacity(self.showNotes ? 1 : 0)
    }

    private var floatingActionButton: some View {
        GeometryReader { geometry in
            Button(action: { self.showAddNote = true }) {
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
            .offset(
                x: geometry.size.width - 85,
                y: geometry.size.height - 65)
        }
    }
}
