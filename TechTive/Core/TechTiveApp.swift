import FirebaseCore
import GoogleSignIn
import SwiftUI

#if DEBUG
    import Inject
#endif

// Test comment for pre-commit hook
@main struct TechTiveApp: App {
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var notesViewModel: NotesViewModel

    init() {
        FirebaseApp.configure()

        // Configure Google Sign In
        guard let clientID = FirebaseApp.app()?.options.clientID else { fatalError("No client ID found in Firebase configuration") }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        let auth = AuthViewModel()
        _authViewModel = StateObject(wrappedValue: auth)
        _notesViewModel = StateObject(wrappedValue: NotesViewModel(authViewModel: auth))
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(self.authViewModel)
                    .environmentObject(self.notesViewModel)
            }
        }
    }
}
