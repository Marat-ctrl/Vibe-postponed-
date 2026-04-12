import SwiftUI
import FirebaseAuth
import Combine
import Firebase 


struct SearchView: View {
    @StateObject private var searchVM = SearchViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                if themeManager.current.isVibe {
                    VibeBackground()
                } else {
                    themeManager.current.background
                        .ignoresSafeArea()
                }
                
                VStack(spacing: 0) {
                    VibeNavBar(title: "поиск", scrollOffset: 0)
                        .environmentObject(themeManager)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.current.textSecondary)
                            TextField("", text: $searchVM.searchText,
                                prompt: Text("поиск пользователей")
                                    .foregroundColor(Color(hex: "#333333")))
                                .font(.system(size: 15))
                                .foregroundColor(themeManager.current.textPrimary)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(themeManager.current.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(themeManager.current.surfaceBorder, lineWidth: 0.5)
                                )
                        )
                        
                        if !searchVM.searchText.isEmpty {
                            Button {
                                searchVM.searchText = ""
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(themeManager.current.textSecondary)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(themeManager.current.surface)
                                    )
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .animation(.easeInOut(duration: 0.2), value: searchVM.searchText.isEmpty)
                    
                    if searchVM.isLoading {
                        Spacer()
                        ProgressView().tint(themeManager.current.accent)
                        Spacer()
                    } else if searchVM.users.isEmpty && !searchVM.searchText.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Text("✦")
                                .font(.system(size: 28))
                                .foregroundColor(themeManager.current.accent.opacity(0.3))
                            Text("никого не найдено")
                                .font(.system(size: 15, weight: .light))
                                .foregroundColor(themeManager.current.textSecondary)
                        }
                        Spacer()
                    } else if searchVM.searchText.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Text("✦")
                                .font(.system(size: 28))
                                .foregroundColor(themeManager.current.accent.opacity(0.2))
                            Text("найди кого-нибудь")
                                .font(.system(size: 15, weight: .light))
                                .foregroundColor(themeManager.current.textSecondary.opacity(0.5))
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(searchVM.users) { user in
                                    NavigationLink(destination:
                                        UserProfileView(userId: user.id)
                                            .environmentObject(authVM)
                                            .environmentObject(themeManager)
                                    ) {
                                        HStack(spacing: 14) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(Color(hex: "#1A1218"))
                                                    .frame(width: 46, height: 46)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 14)
                                                            .stroke(themeManager.current.accent.opacity(0.2), lineWidth: 0.5)
                                                    )
                                                Text(String(user.username.prefix(1)).uppercased())
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(themeManager.current.accent)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(user.username)
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundColor(themeManager.current.textPrimary)
                                                if !user.bio.isEmpty {
                                                    Text(user.bio)
                                                        .font(.system(size: 12, weight: .light))
                                                        .foregroundColor(themeManager.current.textSecondary)
                                                        .lineLimit(1)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12))
                                                .foregroundColor(themeManager.current.textSecondary.opacity(0.4))
                                        }
                                        .padding(14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(themeManager.current.surface)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(themeManager.current.surfaceBorder, lineWidth: 0.5)
                                                )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}
