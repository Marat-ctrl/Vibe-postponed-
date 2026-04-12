import Foundation

struct VUser: Identifiable, Codable {
    let id: String
    var username: String
    var displayName: String
    var bio: String
    var avatarURL: String
    var followersCount: Int
    var followingCount: Int
    var postsCount: Int
    var createdAt: Date
    
    init(id: String, username: String, displayName: String) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.bio = ""
        self.avatarURL = ""
        self.followersCount = 0
        self.followingCount = 0
        self.postsCount = 0
        self.createdAt = Date()
    }
}
