import Foundation

struct Comment: Identifiable, Codable {
    let id: String
    let authorId: String
    var authorUsername: String
    var text: String
    var createdAt: Date
    
    init(id: String, authorId: String, authorUsername: String, text: String) {
        self.id = id
        self.authorId = authorId
        self.authorUsername = authorUsername
        self.text = text
        self.createdAt = Date()
    }
}
