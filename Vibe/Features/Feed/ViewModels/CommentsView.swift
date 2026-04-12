import SwiftUI
import FirebaseAuth
import Combine



struct CommentsView: View {
    let postId: String
    let postText: String
    let postAuthor: String
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var commentsVM: CommentsViewModel
    @State private var text = ""
    @FocusState private var focused: Bool
    
    init(postId: String, postText: String, postAuthor: String) {
        self.postId = postId
        self.postText = postText
        self.postAuthor = postAuthor
        _commentsVM = StateObject(wrappedValue: CommentsViewModel(postId: postId))
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
                VibeNavBar(title: "комментарии", scrollOffset: 0)  {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .medium))
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
                    VStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(postAuthor)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Text(postText)
                                .font(.system(size: 15, weight: .light))
                                .foregroundColor(Color(hex: "#CCCCCC"))
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(themeManager.current.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(themeManager.current.surfaceBorder, lineWidth: 0.5)
                                )
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        Rectangle()
                            .fill(themeManager.current.surfaceBorder)
                            .frame(height: 0.5)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 16)
                        
                        if commentsVM.isLoading {
                            ProgressView()
                                .tint(themeManager.current.accent)
                                .padding(.top, 20)
                        } else if commentsVM.comments.isEmpty {
                            VStack(spacing: 8) {
                                Text("✦")
                                    .font(.system(size: 24))
                                    .foregroundColor(themeManager.current.accent.opacity(0.2))
                                Text("пока нет комментариев")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(themeManager.current.textSecondary)
                            }
                            .padding(.top, 40)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(commentsVM.comments) { comment in
                                    HStack(alignment: .top, spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(hex: "#1A1218"))
                                                .frame(width: 34, height: 34)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(themeManager.current.accent.opacity(0.2), lineWidth: 0.5)
                                                )
                                            Text(String(comment.authorUsername.prefix(1)).uppercased())
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(themeManager.current.accent)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(comment.authorUsername)
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundColor(themeManager.current.textPrimary)
                                                Spacer()
                                                Text(timeAgo(from: comment.createdAt))
                                                    .font(.system(size: 11, weight: .light))
                                                    .foregroundColor(themeManager.current.textSecondary)
                                            }
                                            Text(comment.text)
                                                .font(.system(size: 14, weight: .light))
                                                .foregroundColor(themeManager.current.isLight ? Color(hex: "#4A5568") : Color(hex:  "#CCCCCC"))
                                                .lineSpacing(3)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.bottom, 100)
                        }
                    }
                }
                
                HStack(spacing: 10) {
                    TextField("", text: $text,
                        prompt: Text("комментарий...")
                            .foregroundColor(Color(hex: "#333333")))
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .focused($focused)
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
                        HapticManager.impact(.soft)
                        Task {
                            let msg = text
                            text = ""
                            await commentsVM.addComment(
                                text: msg,
                                authorId: authVM.userSession?.uid ?? "",
                                authorUsername: authVM.currentUser?.username ?? ""
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
                .background(themeManager.current.background)
            }
        }
        .hideKeyboardOnTap()
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { focused = true }
    }
    
    func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "только что" }
        if seconds < 3600 { return "\(seconds / 60) мин" }
        if seconds < 86400 { return "\(seconds / 3600) ч" }
        return "\(seconds / 86400) д"
    }
}
