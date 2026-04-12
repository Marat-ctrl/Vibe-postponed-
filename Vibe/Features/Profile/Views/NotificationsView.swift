import SwiftUI
import UserNotifications

struct NotificationsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = false
    @State private var likesEnabled = true
    @State private var commentsEnabled = true
    @State private var messagesEnabled = true
    @State private var followsEnabled = true
    @State private var permissionDenied = false
    
    var body: some View {
        ZStack {
            if themeManager.current.isVibe {
                VibeBackground()
            } else {
                themeManager.current.background
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                VibeNavBar(title: "уведомления", scrollOffset: 0) {
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
                        VStack(spacing: 0) {
                            toggleRow(
                                icon: "bell.fill",
                                title: "push-уведомления",
                                subtitle: "включить все уведомления",
                                isOn: $notificationsEnabled,
                                isFirst: true,
                                isLast: true
                            ) {
                                if notificationsEnabled {
                                    requestPermission()
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        if permissionDenied {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 13))
                                    .foregroundColor(themeManager.current.accent)
                                Text("разрешите уведомления в настройках iPhone")
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundColor(themeManager.current.textSecondary)
                            }
                            .padding(.horizontal, 28)
                        }
                        
                        if notificationsEnabled {
                            VStack(spacing: 0) {
                                toggleRow(icon: "heart.fill", title: "лайки", subtitle: "когда лайкают посты", isOn: $likesEnabled, isFirst: true, isLast: false)
                                Divider().background(themeManager.current.surfaceBorder).padding(.leading, 56)
                                toggleRow(icon: "bubble.right.fill", title: "комментарии", subtitle: "новые комментарии", isOn: $commentsEnabled, isFirst: false, isLast: false)
                                Divider().background(themeManager.current.surfaceBorder).padding(.leading, 56)
                                toggleRow(icon: "message.fill", title: "сообщения", subtitle: "новые сообщения", isOn: $messagesEnabled, isFirst: false, isLast: false)
                                Divider().background(themeManager.current.surfaceBorder).padding(.leading, 56)
                                toggleRow(icon: "person.fill.badge.plus", title: "подписки", subtitle: "новые подписчики", isOn: $followsEnabled, isFirst: false, isLast: true)
                            }
                            .padding(.horizontal, 24)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                    .animation(.easeInOut(duration: 0.3), value: notificationsEnabled)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { checkPermission() }
    }
    
    @ViewBuilder
    func toggleRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>, isFirst: Bool, isLast: Bool, onChange: (() -> Void)? = nil) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(themeManager.current.accent)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(themeManager.current.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(themeManager.current.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(themeManager.current.accent)
                .onChange(of: isOn.wrappedValue) {
                    HapticManager.selection()
                    onChange?()
                }
        }
        .padding(16)
        .background(themeManager.current.surface)
        .overlay(
            RoundedRectangle(cornerRadius: isFirst && isLast ? 14 : (isFirst ? 14 : (isLast ? 14 : 0)))
                .stroke(themeManager.current.surfaceBorder, lineWidth: 0.5)
        )
        .clipShape(
            .rect(
                topLeadingRadius: isFirst ? 14 : 0,
                bottomLeadingRadius: isLast ? 14 : 0,
                bottomTrailingRadius: isLast ? 14 : 0,
                topTrailingRadius: isFirst ? 14 : 0
            )
        )
    }
    
    func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                notificationsEnabled = granted
                permissionDenied = !granted
            }
        }
    }
}
