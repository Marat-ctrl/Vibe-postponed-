import SwiftUI
import FirebaseFirestore
import Combine
import FirebaseAuth


struct MyPostsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var posts: [Post] = []
    @State private var isLoading = true
    private var db = Firestore.firestore()
    
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
                
                if isLoading {
                    Spacer()
                    ProgressView().tint(themeManager.current.accent)
                    Spacer()
                } else if posts.isEmpty {
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
                                    await likePost(post: post)
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
        .task { await fetchPosts() }
    }
    
    func fetchPosts() async {
        guard let uid = authVM.userSession?.uid else { return }
        isLoading = true
        let snapshot = try? await db.collection("posts")
            .whereField("authorId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        posts = snapshot?.documents.compactMap { doc -> Post? in
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
        isLoading = false
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
        await fetchPosts()
    }
}
