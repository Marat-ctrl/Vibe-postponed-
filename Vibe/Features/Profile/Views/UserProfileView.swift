import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine


struct UserProfileView: View {
    let userId: String
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var isFollowing = false
    @State private var isProcessing = false
    @State private var user: VUser?
    @State private var userPosts: [Post] = []
    @State private var listener: ListenerRegistration?
    @State private var chatId: String?
    @State private var navigateToChat = false
    var db = Firestore.firestore()
    
    var isCurrentUser: Bool {
        authVM.userSession?.uid == userId
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
                VibeNavBar(title: user?.username ?? "", scrollOffset: 0) {
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
                    VStack(spacing: 0) {
                        if let user = user {
                            VStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color(hex: "#1A1218"))
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [
                                                            themeManager.current.accent.opacity(0.4),
                                                            themeManager.current.accent.opacity(0)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 0.5
                                                )
                                        )
                                    Text(String(user.username.prefix(1)).uppercased())
                                        .font(.system(size: 28, weight: .semibold))
                                        .foregroundColor(themeManager.current.accent)
                                }
                                
                                VStack(spacing: 4) {
                                    Text("@\(user.username)")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                    if !user.bio.isEmpty {
                                        Text(user.bio)
                                            .font(.system(size: 13, weight: .light))
                                            .foregroundColor(themeManager.current.textSecondary)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                
                                HStack(spacing: 0) {
                                    statCell(value: "\(userPosts.count)", label: "посты")
                                    Rectangle()
                                        .fill(themeManager.current.surfaceBorder)
                                        .frame(width: 0.5)
                                        .padding(.vertical, 12)
                                    statCell(value: "\(user.followersCount)", label: "подписчики")
                                    Rectangle()
                                        .fill(themeManager.current.surfaceBorder)
                                        .frame(width: 0.5)
                                        .padding(.vertical, 12)
                                    statCell(value: "\(user.followingCount)", label: "подписки")
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(themeManager.current.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(themeManager.current.surfaceBorder, lineWidth: 0.5)
                                        )
                                )
                                
                                if !isCurrentUser {
                                    HStack(spacing: 10) {
                                        Button {
                                            HapticManager.impact(.medium)
                                            Task { await handleFollow() }
                                        } label: {
                                            ZStack {
                                                if isProcessing {
                                                    ProgressView().tint(isFollowing ? themeManager.current.textSecondary : .white)
                                                } else {
                                                    Text(isFollowing ? "отписаться" : "подписаться")
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(isFollowing ? themeManager.current.textSecondary : .white)
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 44)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(isFollowing ? themeManager.current.surface : themeManager.current.accent)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 14)
                                                            .stroke(isFollowing ? themeManager.current.surfaceBorder : Color.clear, lineWidth: 0.5)
                                                    )
                                            )
                                            .animation(.easeInOut(duration: 0.2), value: isFollowing)
                                        }
                                        .disabled(isProcessing)
                                        
                                        Button {
                                            Task { await openChat() }
                                        } label: {
                                            Image(systemName: "message")
                                                .font(.system(size: 15))
                                                .foregroundColor(themeManager.current.textSecondary)
                                                .frame(width: 44, height: 44)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .fill(themeManager.current.surface)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 14)
                                                                .stroke(themeManager.current.surfaceBorder, lineWidth: 0.5)
                                                        )
                                                )
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            .padding(.bottom, 24)
                            
                            if userPosts.isEmpty {
                                VStack(spacing: 8) {
                                    Text("✦")
                                        .font(.system(size: 24))
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
                                            guard let uid = authVM.userSession?.uid else { return }
                                            let likeRef = db.collection("posts").document(post.id)
                                                .collection("likes").document(uid)
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
                                        })
                                        .environmentObject(themeManager)
                                        .padding(.horizontal, 16)
                                    }
                                }
                                .padding(.bottom, 100)
                            }
                        } else {
                            ProgressView()
                                .tint(themeManager.current.accent)
                                .padding(.top, 100)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToChat) {
            if let chatId = chatId, let user = user {
                ChatView(
                    chatId: chatId,
                    otherUsername: user.username,
                    otherUserId: userId
                )
                .environmentObject(authVM)
                .environmentObject(themeManager)
            }
        }
        .task {
            await checkIfFollowing()
            await fetchUserPosts()
            startListening()
        }
        .onDisappear {
            listener?.remove()
            listener = nil
        }
    }
    
    @ViewBuilder
    func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .light))
                .foregroundColor(themeManager.current.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }
    
    func startListening() {
        listener?.remove()
        listener = db.collection("users").document(userId)
            .addSnapshotListener { snapshot, _ in
                guard let data = snapshot?.data() else { return }
                var u = VUser(id: userId, username: data["username"] as? String ?? "", displayName: data["displayName"] as? String ?? "")
                u.followersCount = data["followersCount"] as? Int ?? 0
                u.followingCount = data["followingCount"] as? Int ?? 0
                u.bio = data["bio"] as? String ?? ""
                user = u
            }
    }
    
    func checkIfFollowing() async {
        guard let currentUserId = authVM.userSession?.uid else { return }
        let doc = try? await db.collection("users").document(currentUserId)
            .collection("following").document(userId).getDocument()
        isFollowing = doc?.exists ?? false
    }
    
    func handleFollow() async {
        guard let currentUserId = authVM.userSession?.uid, !isProcessing else { return }
        isProcessing = true
        let followingRef = db.collection("users").document(currentUserId).collection("following").document(userId)
        let followerRef = db.collection("users").document(userId).collection("followers").document(currentUserId)
        let currentUserRef = db.collection("users").document(currentUserId)
        let targetUserRef = db.collection("users").document(userId)
        do {
            let exists = try await followingRef.getDocument().exists
            if exists {
                try await followingRef.delete()
                try await followerRef.delete()
                try await currentUserRef.setData(["followingCount": FieldValue.increment(Int64(-1))], merge: true)
                try await targetUserRef.setData(["followersCount": FieldValue.increment(Int64(-1))], merge: true)
                isFollowing = false
            } else {
                try await followingRef.setData(["userId": userId, "createdAt": Timestamp(date: Date())])
                try await followerRef.setData(["userId": currentUserId, "createdAt": Timestamp(date: Date())])
                try await currentUserRef.setData(["followingCount": FieldValue.increment(Int64(1))], merge: true)
                try await targetUserRef.setData(["followersCount": FieldValue.increment(Int64(1))], merge: true)
                isFollowing = true
            }
        } catch { print("Follow error: \(error)") }
        isProcessing = false
    }
    
    func openChat() async {
        guard let currentUserId = authVM.userSession?.uid,
              let currentUsername = authVM.currentUser?.username,
              let otherUsername = user?.username else { return }
        let vm = ChatViewModel()
        let id = await vm.createOrOpenChat(
            currentUserId: currentUserId,
            currentUsername: currentUsername,
            otherUserId: userId,
            otherUsername: otherUsername
        )
        chatId = id
        navigateToChat = true
    }
    
    func fetchUserPosts() async {
        let snapshot = try? await db.collection("posts")
            .whereField("authorId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        userPosts = snapshot?.documents.compactMap { doc -> Post? in
            let data = doc.data()
            var post = Post(id: doc.documentID, authorId: data["authorId"] as? String ?? "", authorUsername: data["authorUsername"] as? String ?? "", text: data["text"] as? String ?? "")
            post.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            post.likesCount = data["likesCount"] as? Int ?? 0
            post.commentsCount = data["commentsCount"] as? Int ?? 0
            return post
        } ?? []
    }
}
