import SwiftUI
import FirebaseFirestore
import Combine
import FirebaseAuth

struct PostCardView: View {
    let post: Post
    let onLike: () async -> Void
    var onAuthorTap: (() -> Void)? = nil
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authVM: AuthViewModel
    @State private var liked = false
    @State private var likeScale: CGFloat = 1.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Button {
                    onAuthorTap?()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.current.isLight
                                ? themeManager.current.accent.opacity(0.1)
                                : Color(hex: "#1A1218"))
                            .frame(width: 40, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.current.accent.opacity(0.2), lineWidth: 0.5)
                            )
                        Text(String(post.authorUsername.prefix(1)).uppercased())
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(themeManager.current.accent)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("@\(post.authorUsername)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeManager.current.textPrimary)
                        
                        if post.authorId == authVM.userSession?.uid {
                            Text("вы")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(themeManager.current.accent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(themeManager.current.accent.opacity(0.1))
                                        .overlay(Capsule().stroke(themeManager.current.accent.opacity(0.2), lineWidth: 0.5))
                                )
                        }
                    }
                    Text(timeAgo(from: post.createdAt))
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(themeManager.current.textSecondary)
                }
                
                Spacer()
                
                Text("✦")
                    .font(.system(size: 10))
                    .foregroundColor(themeManager.current.accent.opacity(0.3))
            }
            
            Text(post.text)
                .font(.system(size: 15, weight: .light))
                .foregroundColor(themeManager.current.isLight ? Color(hex: "#4A5568") : Color(hex: "#CCCCCC"))
                .lineSpacing(4)
            
            HStack(spacing: 20) {
                Button {
                    HapticManager.impact(.soft)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        likeScale = 1.4
                    }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.1)) {
                        likeScale = 1.0
                    }
                    Task {
                        await onLike()
                        guard let uid = authVM.userSession?.uid else { return }
                        let db = Firestore.firestore()
                        let doc = try? await db.collection("posts").document(post.id)
                            .collection("likes").document(uid).getDocument()
                        liked = doc?.exists ?? false
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: liked ? "heart.fill" : "heart")
                            .font(.system(size: 13))
                            .foregroundColor(liked ? themeManager.current.accent : themeManager.current.textSecondary)
                            .scaleEffect(likeScale)
                        Text("\(post.likesCount)")
                            .font(.system(size: 13))
                            .foregroundColor(liked ? themeManager.current.accent : themeManager.current.textSecondary)
                    }
                }
                
                NavigationLink(destination:
                    CommentsView(postId: post.id, postText: post.text, postAuthor: post.authorUsername)
                        .environmentObject(themeManager)
                        .environmentObject(authVM)
                ) {
                    HStack(spacing: 5) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 13))
                            .foregroundColor(themeManager.current.textSecondary)
                        Text("\(post.commentsCount)")
                            .font(.system(size: 13))
                            .foregroundColor(themeManager.current.textSecondary)
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.current.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            themeManager.current == .aqua
                                ? themeManager.current.accent.opacity(0.2)
                                : themeManager.current.surfaceBorder,
                            lineWidth: themeManager.current == .aqua ? 1 : 0.5
                        )
                )
                .shadow(
                    color: themeManager.current.isLight
                        ? themeManager.current.accent.opacity(0.06)
                        : Color.clear,
                    radius: 8, x: 0, y: 2
                )
        )
        .task {
            guard let uid = authVM.userSession?.uid else { return }
            let db = Firestore.firestore()
            let doc = try? await db.collection("posts").document(post.id)
                .collection("likes").document(uid).getDocument()
            liked = doc?.exists ?? false
        }
    }
    
    func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "только что" }
        if seconds < 3600 { return "\(seconds / 60) мин" }
        if seconds < 86400 { return "\(seconds / 3600) ч" }
        if seconds < 604800 { return "\(seconds / 86400) д" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}
