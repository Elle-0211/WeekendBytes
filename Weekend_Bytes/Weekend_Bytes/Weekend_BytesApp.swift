import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct WeekendBytesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // Instantiate a single AppManager instance for the entire app.
    @StateObject var appManager = AppManager()
    @StateObject var userVM = UserViewModel()
    
    var body: some Scene {
            WindowGroup {
                if appManager.isLoggedIn {
                    ContentView()
                        .environmentObject(userVM)
                        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserDeletedAccount"))) { _ in
                            appManager.isLoggedIn = false
                        }
                } else {
                    SplashScreen()
                        .environmentObject(appManager)
                        .environmentObject(userVM)
                }
            }
        }
    }

