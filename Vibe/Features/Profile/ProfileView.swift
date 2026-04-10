import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine


struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var postsCount = 0
    @State private var userPosts: [Post] = []
    @State private var showEditProfile = false
    @State private var scrollOffset: CGFloat = 0
    private var db = Firestore.firestore()
    
    let columns = [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)]
    
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
                        Button {
                            showEditProfile = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.current.textSecondary)
                                .frame(width: 34, height: 34)
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
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: ScrollOffsetKey.self,
                                    value: geo.frame(in: .named("profileScroll")).minY
                                )
                            }
                            .frame(height: 0)
                            
                            VStack(spacing: 20) {
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
                                    Text(authVM.currentUser?.username ?? "—")
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
                                        .foregroundColor(themeManager.current.textSecondary.opacity(0.5))
                                }
                                
                                HStack(spacing: 0) {
                                    statCell(value: "\(userPosts.count)", label: "посты")
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
                                
                                Button {
                                    showEditProfile = true
                                } label: {
                                    Text("редактировать профиль")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 42)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(themeManager.current.surface)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(themeManager.current.surfaceBorder, lineWidth: 0.5)
                                                )
                                        )
                                }
                                .padding(.horizontal, 24)
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 24)
                            
                            Divider()
                                .background(themeManager.current.surfaceBorder)
                            
                            if userPosts.isEmpty {
                                VStack(spacing: 8) {
                                    Text("✦")
                                        .font(.system(size: 28))
                                        .foregroundColor(themeManager.current.accent.opacity(0.2))
                                    Text("нет постов")
                                        .font(.system(size: 14, weight: .light))
                                        .foregroundColor(themeManager.current.textSecondary)
                                }
                                .padding(.top, 40)
                            } else {
                                LazyVStack(spacing: 10) {
                                    ForEach(userPosts) { post in
                                        PostCardView(post: post, onLike: {
                                            await likePost(post: post)
                                        })
                                        .environmentObject(themeManager)
                                        .padding(.horizontal, 16)
                                    }
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 100)
                            }
                            
                            Divider()
                                .background(themeManager.current.surfaceBorder)
                                .padding(.top, 24)
                            
                            VStack(spacing: 10) {
                                HStack {
                                    Text("тема")
                                        .font(.system(size: 14))
                                        .foregroundColor(themeManager.current.textSecondary)
                                    Spacer()
                                }
                                .padding(.horizontal, 24)
                                
                                HStack(spacing: 10) {
                                    ForEach(AppTheme.allCases, id: \.self) { theme in
                                        Button {
                                            HapticManager.selection()
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                themeManager.current = theme
                                            }
                                        } label: {
                                            VStack(spacing: 8) {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .fill(theme == .dark ? Color(hex: "#111111") : Color(hex: "#0D0018"))
                                                        .frame(height: 56)
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
                                                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                                                }
                                                            }
                                                        )
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 14)
                                                                .stroke(
                                                                    themeManager.current == theme ? themeManager.current.accent : Color(hex: "#2A2A2A"),
                                                                    lineWidth: themeManager.current == theme ? 1.5 : 0.5
                                                                )
                                                        )
                                                    Text(theme == .dark ? "✦" : "◈")
                                                        .font(.system(size: 18))
                                                        .foregroundColor(theme.accent)
                                                }
                                                Text(theme.displayName.lowercased())
                                                    .font(.system(size: 11, weight: .medium))
                                                    .foregroundColor(themeManager.current == theme ? .white : themeManager.current.textSecondary)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            .padding(.top, 24)
                            .padding(.bottom, 16)
                            
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
                                .frame(height: 48)
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
                    .coordinateSpace(name: "profileScroll")
                    .onPreferenceChange(ScrollOffsetKey.self) { value in
                        scrollOffset = value
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
                    .environmentObject(authVM)
                    .environmentObject(themeManager)
            }
            .task {
                await authVM.fetchCurrentUser()
                await fetchUserPosts()
            }
        }
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
        postsCount = userPosts.count
    }
    
    func likePost(post: Post) async {
        guard let uid = authVM.userSession?.uid else { return }
        let db = Firestore.firestore()
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
    
}
