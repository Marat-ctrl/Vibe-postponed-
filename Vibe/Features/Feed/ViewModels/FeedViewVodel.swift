import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class FeedViewModel: ObservableObject {
    
    @Published var posts: [Post] = []
    @Published var isLoading = false
    
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    init() {
        fetchPosts()
    }
    
    deinit {
        listener?.remove()
    }
    
    func fetchPosts() {
        isLoading = true
        listener = db.collection("posts")
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                guard let documents = snapshot?.documents else { return }
                self.posts = documents.compactMap { doc -> Post? in
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
                }
            }
    }
    
    func createPost(text: String, authorUsername: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let postId = UUID().uuidString
        let data: [String: Any] = [
            "id": postId,
            "authorId": uid,
            "authorUsername": authorUsername,
            "authorAvatarURL": "",
            "text": text,
            "likesCount": 0,
            "commentsCount": 0,
            "createdAt": Timestamp(date: Date())
        ]
        try? await db.collection("posts").document(postId).setData(data)
        try? await db.collection("users").document(uid).setData(
            ["postsCount": FieldValue.increment(Int64(1))], merge: true)
    }
    
    func likePost(postId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let likeRef = db.collection("posts").document(postId)
            .collection("likes").document(uid)
        let postRef = db.collection("posts").document(postId)
        do {
            let likeDoc = try await likeRef.getDocument()
            if likeDoc.exists {
                try await likeRef.delete()
                try await postRef.setData(
                    ["likesCount": FieldValue.increment(Int64(-1))], merge: true)
            } else {
                try await likeRef.setData(["uid": uid, "createdAt": Timestamp(date: Date())])
                try await postRef.setData(
                    ["likesCount": FieldValue.increment(Int64(1))], merge: true)
            }
        } catch {
            print("Ошибка лайка: \(error)")
        }
    }
}
