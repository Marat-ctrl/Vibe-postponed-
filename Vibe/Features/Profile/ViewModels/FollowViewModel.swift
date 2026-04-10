import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine
import SwiftUI

@MainActor
class FollowViewModel: ObservableObject {
    
    @Published var isFollowing = false
    @Published var isProcessing = false
    private var db = Firestore.firestore()
    
    func checkIfFollowing(currentUserId: String, targetUserId: String) async {
        guard !currentUserId.isEmpty, !targetUserId.isEmpty else { return }
        let doc = try? await db.collection("users")
            .document(currentUserId)
            .collection("following")
            .document(targetUserId)
            .getDocument()
        isFollowing = doc?.exists ?? false
    }
    
    func toggleFollow(currentUserId: String, targetUserId: String) async {
        guard !isProcessing else { return }
        isProcessing = true
        
        let followingRef = db.collection("users").document(currentUserId)
            .collection("following").document(targetUserId)
        let followerRef = db.collection("users").document(targetUserId)
            .collection("followers").document(currentUserId)
        let currentUserRef = db.collection("users").document(currentUserId)
        let targetUserRef = db.collection("users").document(targetUserId)
        
        do {
            let exists = try await followingRef.getDocument().exists
            
            if exists {
                try await followingRef.delete()
                try await followerRef.delete()
                try await currentUserRef.setData(
                    ["followingCount": FieldValue.increment(Int64(-1))],
                    merge: true
                )
                try await targetUserRef.setData(
                    ["followersCount": FieldValue.increment(Int64(-1))],
                    merge: true
                )
                isFollowing = false
            } else {
                try await followingRef.setData([
                    "userId": targetUserId,
                    "createdAt": Timestamp(date: Date())
                ])
                try await followerRef.setData([
                    "userId": currentUserId,
                    "createdAt": Timestamp(date: Date())
                ])
                try await currentUserRef.setData(
                    ["followingCount": FieldValue.increment(Int64(1))],
                    merge: true
                )
                try await targetUserRef.setData(
                    ["followersCount": FieldValue.increment(Int64(1))],
                    merge: true
                )
                isFollowing = true
            }
            
            print("Follow success — isFollowing: \(isFollowing)")
            
        } catch {
            print("Follow FAILED: \(error.localizedDescription)")
        }
        
        isProcessing = false
    }
}
