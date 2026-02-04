import SwiftUI

// MARK: - Main Content View
// This is the main entry point of the app, starting with a SplashScreen.
struct ContentView: View {
    @StateObject var appManager = AppManager()
    
    var body: some View {
        // The app manager is passed to all relevant views to manage state.
        SplashScreen().environmentObject(appManager)
    }
}
/*#Preview {
    
        ContentView()
    }*/
