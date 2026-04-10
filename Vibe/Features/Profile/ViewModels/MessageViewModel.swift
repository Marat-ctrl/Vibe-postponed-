import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine 

@MainActor
class MessageViewModel: ObservableObject {
    
    @Published var messages: [Message] = []
    @Published var isLoading = false
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    let chatId: String
    
    init(chatId: String) {
        self.chatId = chatId
        fetchMessages()
    }
    
    deinit {
        listener?.remove()
    }
    
    func fetchMessages() {
        isLoading = true
        listener = db.collection("chats").document(chatId)
            .collection("messages")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self else { return }
                self.isLoading = false
                guard let docs = snapshot?.documents else { return }
                self.messages = docs.compactMap { doc -> Message? in
                    let data = doc.data()
                    var msg = Message(
                        id: doc.documentID,
                        senderId: data["senderId"] as? String ?? "",
                        senderUsername: data["senderUsername"] as? String ?? "",
                        text: data["text"] as? String ?? ""
                    )
                    msg.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    return msg
                }
            }
    }
    
    func sendMessage(text: String, senderId: String, senderUsername: String, otherUserId: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let msgId = UUID().uuidString
        let msgData: [String: Any] = [
            "id": msgId,
            "senderId": senderId,
            "senderUsername": senderUsername,
            "text": trimmed,
            "createdAt": Timestamp(date: Date()),
            "isRead": false
        ]
        
        let chatRef = db.collection("chats").document(chatId)
        
        do {
            try await db.collection("chats").document(chatId)
                .collection("messages").document(msgId).setData(msgData)
            try await chatRef.setData([
                "lastMessage": trimmed,
                "lastMessageTime": Timestamp(date: Date()),
                "unreadCount_\(otherUserId)": FieldValue.increment(Int64(1))
            ], merge: true)
        } catch {
            print("Send error: \(error)")
        }
    }
    
    func markAsRead(userId: String) async {
        let chatRef = Firestore.firestore().collection("chats").document(chatId)
        try? await chatRef.setData(["unreadCount_\(userId)": 0], merge: true)
    }
    
}
