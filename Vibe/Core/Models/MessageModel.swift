import Foundation

struct Message: Identifiable, Codable {
    let id: String
    let senderId: String
    let senderUsername: String
    var text: String
    var createdAt: Date
    var isRead: Bool
    
    init(id: String, senderId: String, senderUsername: String, text: String) {
        self.id = id
        self.senderId = senderId
        self.senderUsername = senderUsername
        self.text = text
        self.createdAt = Date()
        self.isRead = false
    }
}
