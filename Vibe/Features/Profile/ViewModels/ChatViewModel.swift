import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine 

@MainActor
class ChatViewModel: ObservableObject {
    
    @Published var chats: [Chat] = []
    @Published var isLoading = false
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        fetchChats()
    }
    
    deinit {
        listener?.remove()
    }
    
    func fetchChats() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        listener = db.collection("chats")
            .whereField("members", arrayContains: uid)
            .order(by: "lastMessageTime", descending: true)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self else { return }
                self.isLoading = false
                guard let docs = snapshot?.documents else { return }
                self.chats = docs.compactMap { doc -> Chat? in
                    let data = doc.data()
                    let members = data["members"] as? [String] ?? []
                    let otherUserId = members.first { $0 != uid } ?? ""
                    let usernames = data["usernames"] as? [String: String] ?? [:]
                    var chat = Chat(
                        id: doc.documentID,
                        otherUserId: otherUserId,
                        otherUsername: usernames[otherUserId] ?? "user"
                    )
                    chat.lastMessage = data["lastMessage"] as? String ?? ""
                    chat.lastMessageTime = (data["lastMessageTime"] as? Timestamp)?.dateValue() ?? Date()
                    chat.unreadCount = data["unreadCount_\(uid)"] as? Int ?? 0
                    return chat
                }
            }
    }
    
    func createOrOpenChat(currentUserId: String, currentUsername: String, otherUserId: String, otherUsername: String) async -> String {
        let chatId = [currentUserId, otherUserId].sorted().joined(separator: "_")
        let chatRef = db.collection("chats").document(chatId)
        
        do {
            let doc = try await chatRef.getDocument()
            if !doc.exists {
                try await chatRef.setData([
                    "members": [currentUserId, otherUserId],
                    "usernames": [currentUserId: currentUsername, otherUserId: otherUsername],
                    "lastMessage": "",
                    "lastMessageTime": Timestamp(date: Date()),
                    "unreadCount_\(currentUserId)": 0,
                    "unreadCount_\(otherUserId)": 0
                ])
            }
        } catch {
            print("Chat create error: \(error)")
        }
        return chatId
    }
    
}
