import SwiftUI
import Combine
import FirebaseAuth

struct FeedView: View {
    @StateObject var feedVM = FeedViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showCreatePost = false
    @State private var scrollOffset: CGFloat = 0
    
    var username: String {
        authVM.currentUser?.username ?? "user"
    }
    
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
                    VibeNavBar(title: "Vibe", isLogo: true, scrollOffset: scrollOffset) {
                        Button { showCreatePost = true } label: {
                            ZStack {
                                Circle()
                                    .fill(themeManager.current.surface)
                                    .frame(width: 34, height: 34)
                                    .overlay(Circle().stroke(themeManager.current.surfaceBorder, lineWidth: 0.5))
                                Image(systemName: "plus")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(themeManager.current.accent)
                            }
                        }
                    }
                    .environmentObject(themeManager)
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: ScrollOffsetKey.self,
                                    value: geo.frame(in: .named("feedScroll")).minY
                                )
                            }
                            .frame(height: 0)
                            
                            if feedVM.isLoading {
                                ProgressView()
                                    .tint(themeManager.current.accent)
                                    .padding(.top, 40)
                            } else if feedVM.posts.isEmpty {
                                VStack(spacing: 12) {
                                    Text("✦")
                                        .font(.system(size: 32))
                                        .foregroundColor(themeManager.current.accent.opacity(0.3))
                                    Text("пока нет постов")
                                        .font(.system(size: 15, weight: .light))
                                        .foregroundColor(themeManager.current.textSecondary)
                                    Text("будь первым")
                                        .font(.system(size: 13, weight: .light))
                                        .foregroundColor(themeManager.current.textSecondary.opacity(0.5))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 60)
                            } else {
                                ForEach(feedVM.posts) { post in
                                    if post.authorId == authVM.userSession?.uid {
                                        PostCardView(
                                            post: post,
                                            onLike: { await feedVM.likePost(postId: post.id) }
                                        )
                                        .environmentObject(themeManager)
                                    } else {
                                        NavigationLink(destination:
                                            UserProfileView(userId: post.authorId)
                                                .environmentObject(authVM)
                                                .environmentObject(themeManager)
                                        ) {
                                            PostCardView(
                                                post: post,
                                                onLike: { await feedVM.likePost(postId: post.id) }
                                            )
                                            .environmentObject(themeManager)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 80)
                    }
                    .coordinateSpace(name: "feedScroll")
                    .onPreferenceChange(ScrollOffsetKey.self) { value in
                        scrollOffset = value
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCreatePost) {
                CreatePostView(feedVM: feedVM, username: username)
                    .environmentObject(themeManager)
            }
        }
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
