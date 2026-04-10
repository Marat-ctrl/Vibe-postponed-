import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine 

@MainActor
class CommentsViewModel: ObservableObject {
    
    @Published var comments: [Comment] = []
    @Published var isLoading = false
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    let postId: String
    
    init(postId: String) {
        self.postId = postId
        fetchComments()
    }
    
    deinit { listener?.remove() }
    
    func fetchComments() {
        isLoading = true
        listener = db.collection("posts").document(postId)
            .collection("comments")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self else { return }
                self.isLoading = false
                self.comments = snapshot?.documents.compactMap { doc -> Comment? in
                    let data = doc.data()
                    var c = Comment(
                        id: doc.documentID,
                        authorId: data["authorId"] as? String ?? "",
                        authorUsername: data["authorUsername"] as? String ?? "",
                        text: data["text"] as? String ?? ""
                    )
                    c.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    return c
                } ?? []
            }
    }
    
    func addComment(text: String, authorId: String, authorUsername: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let id = UUID().uuidString
        let data: [String: Any] = [
            "id": id,
            "authorId": authorId,
            "authorUsername": authorUsername,
            "text": trimmed,
            "createdAt": Timestamp(date: Date())
        ]
        do {
            try await db.collection("posts").document(postId)
                .collection("comments").document(id).setData(data)
            try await db.collection("posts").document(postId)
                .setData(["commentsCount": FieldValue.increment(Int64(1))], merge: true)
        } catch {
            print("Comment error: \(error)")
        }
    }
}
