import SwiftUI

struct MessagesView: View {
    @StateObject private var chatVM = ChatViewModel()
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
                    VibeNavBar(title: "сообщения", scrollOffset: 0)
                        .environmentObject(themeManager)
                    
                    if chatVM.isLoading {
                        Spacer()
                        ProgressView().tint(themeManager.current.accent)
                        Spacer()
                    } else if chatVM.chats.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Text("✦")
                                .font(.system(size: 32))
                                .foregroundColor(themeManager.current.accent.opacity(0.2))
                            Text("нет сообщений")
                                .font(.system(size: 15, weight: .light))
                                .foregroundColor(themeManager.current.textSecondary)
                            Text("найди пользователя и напиши ему")
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(themeManager.current.textSecondary.opacity(0.5))
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(chatVM.chats) { chat in
                                    NavigationLink(destination:
                                        ChatView(
                                            chatId: chat.id,
                                            otherUsername: chat.otherUsername,
                                            otherUserId: chat.otherUserId
                                        )
                                        .environmentObject(authVM)
                                        .environmentObject(themeManager)
                                    ) {
                                        HStack(spacing: 14) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color(hex: "#1A1218"))
                                                    .frame(width: 50, height: 50)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(themeManager.current.accent.opacity(0.2), lineWidth: 0.5)
                                                    )
                                                Text(String(chat.otherUsername.prefix(1)).uppercased())
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(themeManager.current.accent)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Text(chat.otherUsername)
                                                        .font(.system(size: 15, weight: .medium))
                                                        .foregroundColor(.white)
                                                    Spacer()
                                                    Text(timeString(from: chat.lastMessageTime))
                                                        .font(.system(size: 12, weight: .light))
                                                        .foregroundColor(themeManager.current.textSecondary)
                                                }
                                                HStack {
                                                    Text(chat.lastMessage.isEmpty ? "начните общение" : chat.lastMessage)
                                                        .font(.system(size: 13, weight: .light))
                                                        .foregroundColor(themeManager.current.textSecondary)
                                                        .lineLimit(1)
                                                    Spacer()
                                                    if chat.unreadCount > 0 {
                                                        Text("\(chat.unreadCount)")
                                                            .font(.system(size: 11, weight: .semibold))
                                                            .foregroundColor(.white)
                                                            .padding(.horizontal, 7)
                                                            .padding(.vertical, 3)
                                                            .background(themeManager.current.accent)
                                                            .clipShape(Capsule())
                                                    }
                                                }
                                            }
                                        }
                                        .padding(14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(themeManager.current.surface)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 18)
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
    
    func timeString(from date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            let f = DateFormatter()
            f.dateFormat = "HH:mm"
            return f.string(from: date)
        } else {
            let f = DateFormatter()
            f.dateFormat = "d MMM"
            f.locale = Locale(identifier: "ru_RU")
            return f.string(from: date)
        }
    }
}
