import SwiftUI
import Firebase
import Combine

@main
struct VibeApp: App {
    @StateObject var authVM = AuthViewModel()
    @StateObject var themeManager = ThemeManager()
    @State private var showSplash = true
    
    init() {
        FirebaseApp.configure()
        UITabBar.appearance().unselectedItemTintColor = UIColor(white: 0.3, alpha: 1)
        
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                        .environmentObject(themeManager)
                        .transition(.opacity)
                } else {
                    ContentView()
                        .environmentObject(authVM)
                        .environmentObject(themeManager)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: showSplash)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    showSplash = false
                }
            }
        }
    }
}
