import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            themeManager.current.background
                .ignoresSafeArea()
            
            Group {
                if authVM.userSession != nil {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
