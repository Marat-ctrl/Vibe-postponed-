import Foundation

struct Post: Identifiable, Codable {
    let id: String
    let authorId: String
    var authorUsername: String
    var authorAvatarURL: String
    var text: String
    var imageURL: String?
    var likesCount: Int
    var commentsCount: Int
    var createdAt: Date
    
    init(id: String, authorId: String, authorUsername: String, text: String) {
        self.id = id
        self.authorId = authorId
        self.authorUsername = authorUsername
        self.authorAvatarURL = ""
        self.text = text
        self.imageURL = nil
        self.likesCount = 0
        self.commentsCount = 0
        self.createdAt = Date()
    }
}
