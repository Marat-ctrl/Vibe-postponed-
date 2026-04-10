import SwiftUI
import Combine
import Firebase
import FirebaseAuth


struct ChatView: View {
    let chatId: String
    let otherUsername: String
    let otherUserId: String
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var messageVM: MessageViewModel
    @State private var text = ""
    
    init(chatId: String, otherUsername: String, otherUserId: String) {
        self.chatId = chatId
        self.otherUsername = otherUsername
        self.otherUserId = otherUserId
        _messageVM = StateObject(wrappedValue: MessageViewModel(chatId: chatId))
    }
    
    var body: some View {
        ZStack {
            if themeManager.current.isVibe {
                VibeBackground()
            } else {
                themeManager.current.background
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                VibeNavBar(title: otherUsername, scrollOffset: 0)  {
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
                
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(messageVM.messages) { message in
                                MessageBubble(
                                    message: message,
                                    isCurrentUser: message.senderId == authVM.userSession?.uid
                                )
                                .environmentObject(themeManager)
                                .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: messageVM.messages.count) {
                        if let last = messageVM.messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }
                
                HStack(spacing: 10) {
                    TextField("", text: $text,
                        prompt: Text("сообщение...")
                            .foregroundColor(Color(hex: "#333333")))
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(themeManager.current.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(themeManager.current.surfaceBorder, lineWidth: 0.5)
                                )
                        )
                    
                    Button {
                        Task {
                            let msg = text
                            text = ""
                            await messageVM.sendMessage(
                                text: msg,
                                senderId: authVM.userSession?.uid ?? "",
                                senderUsername: authVM.currentUser?.username ?? "",
                                otherUserId: otherUserId
                            )
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(text.isEmpty ? themeManager.current.surface : themeManager.current.accent)
                                .frame(width: 40, height: 40)
                            Image(systemName: "arrow.up")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(text.isEmpty ? themeManager.current.textSecondary : .white)
                        }
                        .animation(.easeInOut(duration: 0.15), value: text.isEmpty)
                    }
                    .disabled(text.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    themeManager.current.surface
                        .overlay(
                            Rectangle()
                                .fill(themeManager.current.surfaceBorder)
                                .frame(height: 0.5),
                            alignment: .top
                        )
                )
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .task {
            if let uid = authVM.userSession?.uid {
                await messageVM.markAsRead(userId: uid)
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isCurrentUser { Spacer(minLength: 60) }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(isCurrentUser ? .white : Color(hex: "#CCCCCC"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(isCurrentUser ? themeManager.current.accent : themeManager.current.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(isCurrentUser ? Color.clear : themeManager.current.surfaceBorder, lineWidth: 0.5)
                            )
                    )
                
                Text(timeString(from: message.createdAt))
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(themeManager.current.textSecondary)
                    .padding(.horizontal, 4)
            }
            
            if !isCurrentUser { Spacer(minLength: 60) }
        }
    }
    
    func timeString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}
