import SwiftUI
import FirebaseFirestore
import Combine 

struct MyPostsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    let posts: [Post]
    let onLike: (Post) async -> Void
    
    var body: some View {
        ZStack {
            if themeManager.current.isVibe {
                VibeBackground()
            } else {
                themeManager.current.background
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                VibeNavBar(title: "мои посты", scrollOffset: 0) {
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
                
                if posts.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("✦")
                            .font(.system(size: 28))
                            .foregroundColor(themeManager.current.accent.opacity(0.2))
                        Text("нет постов")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(themeManager.current.textSecondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(posts) { post in
                                PostCardView(post: post, onLike: {
                                    await onLike(post)
                                })
                                .environmentObject(themeManager)
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
