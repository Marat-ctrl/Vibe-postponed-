import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        TabView {
            FeedView()
                .tabItem { Label("лента", systemImage: "house.fill") }
            
            SearchView()
                .tabItem { Label("поиск", systemImage: "magnifyingglass") }
            
            MessagesView()
                .tabItem { Label("чаты", systemImage: "message.fill") }
            
            ProfileView()
                .tabItem { Label("профиль", systemImage: "person.fill") }
        }
        .tint(themeManager.current.accent)
    }
}
