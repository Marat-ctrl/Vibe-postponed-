import SwiftUI
import FirebaseAuth
import Combine 

struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var showNotifications = false
    @State private var showPrivacy = false
    @State private var showHelp = false
    
    var body: some View {
        ZStack {
            if themeManager.current.isVibe {
                VibeBackground()
            } else {
                themeManager.current.background
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                VibeNavBar(title: "настройки", scrollOffset: 0) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.current.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(themeManager.current.surface)
                                    .overlay(Circle().stroke(themeManager.current.surfaceBorder, lineWidth: 0.5))
                            )
                    }
                }
                .environmentObject(themeManager)
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("тема")
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(themeManager.current.textSecondary)
                                .padding(.horizontal, 4)
                            
                            HStack(spacing: 10) {
                                ForEach(AppTheme.allCases, id: \.self) { theme in
                                    Button {
                                        HapticManager.selection()
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            themeManager.current = theme
                                        }
                                    } label: {
                                        VStack(spacing: 6) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(theme.background)
                                                    .frame(height: 52)
                                                    .overlay(
                                                        Group {
                                                            if theme == .vibe {
                                                                LinearGradient(
                                                                    colors: [
                                                                        Color(hex: "#FF6B9D").opacity(0.3),
                                                                        Color(hex: "#C84FFF").opacity(0.2)
                                                                    ],
                                                                    startPoint: .topLeading,
                                                                    endPoint: .bottomTrailing
                                                                )
                                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                            }
                                                        }
                                                    )
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(
                                                                themeManager.current == theme ? theme.accent : Color(hex: "#2A2A2A").opacity(0.3),
                                                                lineWidth: themeManager.current == theme ? 1.5 : 0.5
                                                            )
                                                    )
                                                
                                                Text(theme == .dark ? "✦" : theme == .vibe ? "◈" : theme == .white ? "○" : "◉")
                                                    .font(.system(size: 18))
                                                    .foregroundColor(theme.accent)
                                            }
                                            
                                            Text(theme.displayName.lowercased())
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundColor(themeManager.current == theme ? themeManager.current.accent : themeManager.current.textSecondary)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        VStack(spacing: 8) {
                            settingsRow(icon: "bell", title: "уведомления") {
                                showNotifications = true
                            }
                            settingsRow(icon: "lock", title: "конфиденциальность") {
                                showPrivacy = true
                            }
                            settingsRow(icon: "questionmark.circle", title: "помощь") {
                                showHelp = true
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Button {
                            authVM.signOut()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                    .font(.system(size: 14))
                                Text("выйти")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(Color(hex: "#FF4466"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(hex: "#FF4466").opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color(hex: "#FF4466").opacity(0.15), lineWidth: 0.5)
                                    )
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showNotifications) {
            NotificationsView().environmentObject(themeManager)
        }
        .navigationDestination(isPresented: $showPrivacy) {
            PrivacyView().environmentObject(themeManager)
        }
        .navigationDestination(isPresented: $showHelp) {
            HelpView().environmentObject(themeManager)
        }
    }
    
    @ViewBuilder
    func settingsRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(themeManager.current.textSecondary)
                    .frame(width: 20)
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(themeManager.current.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.current.textSecondary.opacity(0.4))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(themeManager.current.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(themeManager.current.surfaceBorder, lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
