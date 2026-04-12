import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine


struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var userPosts: [Post] = []
    @State private var showEditProfile = false
    @State private var showPosts = false
    @State private var showSettings = false
    @State private var scrollOffset: CGFloat = 0
    private var db = Firestore.firestore()
    
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
                    VibeNavBar(title: "профиль", scrollOffset: scrollOffset) {
                        EmptyView()
                    }
                    .environmentObject(themeManager)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: ScrollOffsetKey.self,
                                    value: geo.frame(in: .named("profileScroll")).minY
                                )
                            }
                            .frame(height: 0)
                            
                            VStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(Color(hex: "#1A1218"))
                                        .frame(width: 88, height: 88)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 28)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [
                                                            themeManager.current.accent.opacity(0.5),
                                                            themeManager.current.accent.opacity(0)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 0.5
                                                )
                                        )
                                    Text(String(authVM.currentUser?.username.prefix(1) ?? "?").uppercased())
                                        .font(.system(size: 32, weight: .semibold))
                                        .foregroundColor(themeManager.current.accent)
                                }
                                
                                VStack(spacing: 6) {
                                    Text("@\(authVM.currentUser?.username ?? "—")")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    if let bio = authVM.currentUser?.bio, !bio.isEmpty {
                                        Text(bio)
                                            .font(.system(size: 14, weight: .light))
                                            .foregroundColor(themeManager.current.textSecondary)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 40)
                                    }
                                    
                                    Text(authVM.userSession?.email ?? "")
                                        .font(.system(size: 12, weight: .light))
                                        .foregroundColor(themeManager.current.textSecondary.opacity(0.4))
                                }
                            }
                            .padding(.top, 16)
                            .padding(.horizontal, 24)
                            
                            HStack(spacing: 0) {
                                statCell(value: "\(authVM.currentUser?.postsCount ?? 0)", label: "посты")
                                Rectangle()
                                    .fill(themeManager.current.surfaceBorder)
                                    .frame(width: 0.5)
                                    .padding(.vertical, 12)
                                statCell(value: "\(authVM.currentUser?.followersCount ?? 0)", label: "подписчики")
                                Rectangle()
                                    .fill(themeManager.current.surfaceBorder)
                                    .frame(width: 0.5)
                                    .padding(.vertical, 12)
                                statCell(value: "\(authVM.currentUser?.followingCount ?? 0)", label: "подписки")
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(themeManager.current.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(themeManager.current.surfaceBorder, lineWidth: 0.5)
                                    )
                            )
                            .padding(.horizontal, 24)
                            
                            VStack(spacing: 10) {
                                profileRow(icon: "pencil", title: "редактировать профиль") {
                                    showEditProfile = true
                                }
                                profileRow(icon: "square.grid.2x2", title: "мои посты") {
                                    showPosts = true
                                }
                                profileRow(icon: "slider.horizontal.3", title: "настройки") {
                                    showSettings = true
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 100)
                        }
                    }
                    .coordinateSpace(name: "profileScroll")
                    .onPreferenceChange(ScrollOffsetKey.self) { value in
                        scrollOffset = value
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showEditProfile) {
                EditProfileView()
                    .environmentObject(authVM)
                    .environmentObject(themeManager)
            }
            .navigationDestination(isPresented: $showPosts) {
                MyPostsView(posts: userPosts, onLike: { post in
                    await likePost(post: post)
                })
                .environmentObject(authVM)
                .environmentObject(themeManager)
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(authVM)
                    .environmentObject(themeManager)
            }
            .task {
                await authVM.fetchCurrentUser()
                
            }
        }
    }
    
    @ViewBuilder
    func profileRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(themeManager.current.textSecondary)
                    .frame(width: 20)
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
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
    
    @ViewBuilder
    func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .light))
                .foregroundColor(themeManager.current.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }
    
    func likePost(post: Post) async {
        guard let uid = authVM.userSession?.uid else { return }
        let likeRef = db.collection("posts").document(post.id).collection("likes").document(uid)
        let postRef = db.collection("posts").document(post.id)
        let likeDoc = try? await likeRef.getDocument()
        if likeDoc?.exists == true {
            try? await likeRef.delete()
            try? await postRef.setData(["likesCount": FieldValue.increment(Int64(-1))], merge: true)
        } else {
            try? await likeRef.setData(["uid": uid])
            try? await postRef.setData(["likesCount": FieldValue.increment(Int64(1))], merge: true)
        }
        await fetchUserPosts()
    }
    
    func fetchUserPosts() async {
        guard let uid = authVM.userSession?.uid else { return }
        let snapshot = try? await db.collection("posts")
            .whereField("authorId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        userPosts = snapshot?.documents.compactMap { doc -> Post? in
            let data = doc.data()
            var post = Post(
                id: doc.documentID,
                authorId: data["authorId"] as? String ?? "",
                authorUsername: data["authorUsername"] as? String ?? "",
                text: data["text"] as? String ?? ""
            )
            post.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            post.likesCount = data["likesCount"] as? Int ?? 0
            post.commentsCount = data["commentsCount"] as? Int ?? 0
            return post
        } ?? []
    }
}
