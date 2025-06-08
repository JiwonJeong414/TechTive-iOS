import FirebaseCore
import GoogleSignIn
import SwiftUI

#if DEBUG
    import Inject
#endif

// Test comment for pre-commit hook
@main struct TechTiveApp: App {
    // MARK: - Properties

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()

    // MARK: - UI

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .environmentObject(self.authViewModel)
            }
        }
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        FirebaseApp.configure()
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }
        // Add push notification, FCM, etc. setup here if needed
        return true
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
}
