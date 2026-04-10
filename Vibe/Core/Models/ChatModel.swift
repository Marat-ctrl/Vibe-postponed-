import Foundation

struct Chat: Identifiable {
    let id: String
    let otherUserId: String
    var otherUsername: String
    var lastMessage: String
    var lastMessageTime: Date
    var unreadCount: Int
    
    init(id: String, otherUserId: String, otherUsername: String) {
        self.id = id
        self.otherUserId = otherUserId
        self.otherUsername = otherUsername
        self.lastMessage = ""
        self.lastMessageTime = Date()
        self.unreadCount = 0
    }
}
